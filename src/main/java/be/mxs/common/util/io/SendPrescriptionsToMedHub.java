package be.mxs.common.util.io;

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.client.ClientProtocolException;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Pointer;
import be.openclinic.system.SH;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class SendPrescriptionsToMedHub {
	
	static Boolean facture_simple =  false; 
	
	static PreparedStatement ps = null;

	public static void main(String[] args) throws SQLException, ClientProtocolException, IOException {
		//Préparation des paramètres pour se connecter aux bases de données
		String processid=ManagementFactory.getRuntimeMXBean().getName();
		System.out.println(processid+" - Loading primrose configuration "+args[0]);
		try {
			PrimroseLoader.load(args[0], true);
			System.out.println(processid+" - Primrose loaded");
			System.out.println("Second parametter " + args[1]);
			facture_simple = Boolean.parseBoolean(args[1]);
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}
		try {
			MedwanQuery.getInstance(false);
			System.out.println(processid+" - MedwanQuery loaded");
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}

		String assurars = SH.cs("HUB_medhub_assur","'1.19'");
		String stock_uid = SH.cs("HUB_medhhub_stock_uid","'1.1'");
		
		Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
		    //mysql request 
			//PreparedStatement ps = conn.prepareStatement(
				//" SELECT oc_pa.* FROM oc_patientinvoices oc_pa " +
				//"  WHERE oc_pa.oc_patientinvoice_updatetime > '2022-12-01' " +
				//"  and oc_pa.oc_patientinvoice_updatetime <= '2022-12-05' " +
				//"  AND oc_pa.oc_patientinvoice_status='closed' and " +
				//"  exists (SELECT * FROM oc_debets, oc_insurances " +
				//"  WHERE oc_debets.OC_DEBET_INSURANCEUID = oc_insurances.OC_INSURANCE_SERVERID||'.'||oc_insurances.OC_INSURANCE_OBJECTID " +
				//"  AND oc_insurances.OC_INSURANCE_INSURARUID IN (1.1) " +
				//"  AND oc_debets.OC_DEBET_PATIENTINVOICEUID = oc_pa.OC_PATIENTINVOICE_SERVERID||'.'||oc_pa.OC_PATIENTINVOICE_OBJECTID) AND " +
				//"  not exists (select * from oc_pointers where oc_pointer_key= " +
				//"  'MEDH.INV.'||oc_patientinvoice_serverid||'.'||oc_patientinvoice_objectid);"); 
		
		     String request_to_sent  = " select distinct prescr.OC_PRESCR_SERVERID, prescr.OC_PRESCR_OBJECTID from OC_PRESCRIPTIONS prescr, OC_INSURANCES ansur " +
				    	" WHERE OC_PRESCR_UPDATETIME >= ? " +
				    	" AND OC_PRESCR_UPDATETIME <= ? " + 
				    	" AND OC_PRESCR_SERVICESTOCKUID = ? " + 
				    	" and ansur.OC_INSURANCE_PATIENTUID = prescr.OC_PRESCR_PATIENTUID " +
				    	" and ansur.OC_INSURANCE_INSURARUID  in ("+assurars+") " +
				    	" AND not exists (select * from oc_pointers where oc_pointer_key =  "+ 
				    	" concat('MEDH.PRESCR.', OC_PRESCR_SERVERID,'.', OC_PRESCR_OBJECTID )); ";
		
		     System.out.println("Requette a envoyer : " + request_to_sent);
		     
			  //envoyer les factures simples
		      ps = conn.prepareStatement(request_to_sent);
		      ps.setDate(1, new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*1));
		      ps.setDate(2, new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*0));
		      ps.setString (3,stock_uid);
		
		
		//PreparedStatement ps = conn.prepareStatement("SELECT * FROM OC_PATIENTINVOICES WHERE  OC_PATIENTINVOICE_OBJECTID = '4110810';");
		
		
		ResultSet rs = ps.executeQuery();
		int nprescr = 0;
		while(rs.next()) {
			nprescr++;
			System.out.println(nprescr + " ----------------DEBUT DE TRAITEMENT DE L'ENVOIE DE PRESTATION---------------" );
			
			String uid_server = rs.getString("OC_PRESCR_SERVERID")+"."+
						rs.getString("OC_PRESCR_OBJECTID");
			
						String uid = rs.getString("OC_PRESCR_OBJECTID");
						//remm
			
			JsonObject sent = null;
			try {
				sent = MedHub.SendPrescription(uid, MedHub.getToken(),false);
			} catch (ClientProtocolException e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
				System.out.println("Erreur " + e.getMessage());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
				System.out.println("Erreur " + e.getMessage());
			}
			
	          //if(sent!=null) {
			//String messagestatus = "ERROR";
			//System.out.println("Message back " + sent.toString());
			
			System.out.println("resultat apres envoie de la prescription " + sent.toString());
			
			if(sent.getJsonObject("msg_body").getString("status").equalsIgnoreCase("SUCCESS")) {
				
				System.out.println("Status de la response apres envoie de la facture s/consolidee: "+uid_server+" envoye a med hub");
				Pointer.storePointer("MEDH.PRESCR."+uid_server, uid_server);
				
			}else {
				
				Pointer.storePointer("MEDH.ERROR."+uid_server, sent.getJsonObject("msg_body").getString("status"));
				
				System.out.println("Status de la response apres envoie de la prescription : "+uid_server+" La prescription n'as pas ete envoyee!");
				System.out.println("Erreur " + sent.getJsonObject("msg_hd").getString("msg_status").toString());
				
				if(sent.getJsonObject("msg_hd").getString("msg_status").toString().contains("34")) {
					
					Pointer.storePointer("MEDH.ERROR.USER."+uid_server, uid_server);
					
					/*
					 * if(!MedHub.CheckTempUsiSaved(uid_server,1)) {
					 * 
					 * System.out.println("Creer un patient");
					 * System.out.println("Resultat de la creation du patient" +
					 * MedHub.SendPatientToMfpByPrescription(uid_server,
					 * MedHub.getToken()).toString()); //Enregistrer l'Isu temporaire
					 * MedHub.SaveTempisu(uid_server,1); //et puis renvoyer la facture a l'aide de
					 * l'isu temporaire
					 * 
					 * 
					 * System.out.println("Envoie de la facture apres creation du patient " );
					 * 
					 * JsonObject sent2 = MedHub.SendPrescription(uid, MedHub.getToken(),true);
					 * 
					 * System.out.
					 * println("resultat de l'envoie de la prescription apres creation du patient "
					 * + sent2.toString());
					 * 
					 * 
					 * if(sent2.getJsonObject("msg_body").getString("status").equalsIgnoreCase(
					 * "SUCCESS")){ System.out.println("Facture apres creation du patient"
					 * +uid_server+" envoye a med hub");
					 * Pointer.storePointer("MEDH.PRESCR."+uid_server, uid_server); }else {
					 * System.out.
					 * println("Erreur d'envoie de la prescription apres creation du patient" +
					 * sent2.getJsonObject("msg_body").toString()); }
					 * 
					 * }else { //renvoyer la prescription a l'aide de l'isu temporaire
					 * //System.out.println("Envoie avec l'isu sauvegardee  " +
					 * MedHub.SendInvoice(uid, MedHub.getToken(),true,facture_simple).toString());
					 * 
					 * JsonObject sent3 = MedHub.SendPrescription(uid, MedHub.getToken(),true);
					 * 
					 * System.out.println("Envoie avec l'isu sauvegardee  " + sent3.toString());
					 * 
					 * if(sent3.getJsonObject("msg_body").getString("status").equalsIgnoreCase(
					 * "SUCCESS")){ System.out.println("La prescription apres creation du patient "
					 * +uid_server+" envoye a med hub");
					 * Pointer.storePointer("MEDH.PRESCR."+uid_server, uid_server); }else {
					 * System.out.println("Error apres creation du patient" +
					 * sent3.getJsonObject("msg_body").toString()); } }
					 */
				}else {
					if(sent.getJsonObject("msg_hd").getString("msg_status").toString().contains("-41")) {
						System.out.println("prescription dupliquee!");
						Pointer.storePointer("MEDH.PRESCR."+uid_server, uid_server);
					}else {
					System.out.println("Autre probleme!");
					}
				}	
			}
			System.out.println(" ---------------FIN DE TRAITEMENT DE L'ENVOIE PRESTATION--------" );
		}
		
		rs.close();
		ps.close();
		conn.close();
		
		//System.exit(0);
	}

}
