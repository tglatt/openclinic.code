package be.mxs.common.util.io;

import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.Date;
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

public class SendInvoicesToMedHub {
	
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

		
		
		Date debut = new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*0 - SH.getTimeHour()* 12);
		Date fin = new java.sql.Date(new java.util.Date().getTime()+SH.getTimeDay()*1 - SH.getTimeHour()* 6);
		
		
		System.out.println("Debut: " +debut);
		System.out.println("Fin: " +fin);
		
		
		ExecuteOperation( debut ,  fin);
		
		//test de message 
		//String invoiceuid = "";
		//String messageconnent = "";
		 //invoiceuid = "4274803";
		// messageconnent = "Contenu du message";	 
		 //String token = MedHub.getToken();	
		//MedHub.SendMessage(invoiceuid,messageconnent, "Horanimana Henri" ,token);
	}
		
		
		public static void ExecuteOperation(Date debut , Date fin) throws SQLException {
		
	     String assurars = SH.cs("HUB_medhub_assur","1.19");	
			
		Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
		
		    //mysql request 
			//PreparedStatement ps = conn.prepareStatement(
				//" SELECT oc_pa.* FROM oc_patientinvoices oc_pa " +
				//"  WHERE oc_pa.oc_patientinvoice_updatetime >= '2022-12-01' " +
				//"  and oc_pa.oc_patientinvoice_updatetime < '2022-12-05' " +
				//"  AND oc_pa.oc_patientinvoice_status='closed' and " +
				//"  exists (SELECT * FROM oc_debets, oc_insurances " +
				//"  WHERE oc_debets.OC_DEBET_INSURANCEUID = oc_insurances.OC_INSURANCE_SERVERID||'.'||oc_insurances.OC_INSURANCE_OBJECTID " +
				//"  AND oc_insurances.OC_INSURANCE_INSURARUID IN (1.1) " +
				//"  AND oc_debets.OC_DEBET_PATIENTINVOICEUID = oc_pa.OC_PATIENTINVOICE_SERVERID||'.'||oc_pa.OC_PATIENTINVOICE_OBJECTID) AND " +
				//"  not exists (select * from oc_pointers where oc_pointer_key= " +
				//"  'MEDH.INV.'||oc_patientinvoice_serverid||'.'||oc_patientinvoice_objectid);"); 
		
		if(facture_simple) {
			//envoyer les factures simples
		    ps = conn.prepareStatement(
				" SELECT oc_pa.oc_patientinvoice_serverid, oc_pa.oc_patientinvoice_objectid   FROM oc_patientinvoices oc_pa " +
				" WHERE oc_pa.oc_patientinvoice_updatetime >= ? " +
				" AND oc_pa.oc_patientinvoice_updatetime <= ? " +
				" AND oc_pa.oc_patientinvoice_status='closed' " +
				//" AND oc_pa.oc_patientinvoice_acceptationuid !='' " +
				//" AND oc_pa.oc_patientinvoice_acceptationuid !='NULL' " +
				" AND NOT exists (select * from oc_pointers where oc_pointer_key  = concat( 'MEDH.INV.',oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid )); ");
		}else {
			//envoyer les factures consolidee de la periode 
			 ps = conn.prepareStatement(
					 " SELECT oc_pa.oc_patientinvoice_serverid, oc_pa.oc_patientinvoice_objectid FROM oc_patientinvoices oc_pa, OC_SUMMARYINVOICES cons, OC_SUMMARYINVOICEITEMS lien " +
					 " WHERE cons.OC_SUMMARYINVOICE_UPDATEDATETIME >= ? " +
					 " AND cons.OC_SUMMARYINVOICE_UPDATEDATETIME <= ? "+
					 " AND cons.OC_SUMMARYINVOICE_STATUS ='closed' "+
					 " and cons.OC_SUMMARYINVOICE_VALIDATED !='' "+
					 " AND cons.OC_SUMMARYINVOICE_VALIDATED !='NULL' " +
					 " and lien.OC_ITEM_PATIENTINVOICEUID = concat( oc_pa.OC_PATIENTINVOICE_SERVERID ,'.' , oc_pa.OC_PATIENTINVOICE_OBJECTID )  "+
					 " and lien.OC_ITEM_SUMMARYINVOICEUID = concat( cons.OC_SUMMARYINVOICE_SERVERID , '.', cons.OC_SUMMARYINVOICE_OBJECTID ) "+
					 " AND not exists (select * from oc_pointers where oc_pointer_key  = CONCAT( 'MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid )); "
					 );
			
		}
		
		ps.setDate(1, debut);
		ps.setDate(2, fin);
	
		//PreparedStatement ps = conn.prepareStatement("SELECT * FROM OC_PATIENTINVOICES WHERE  OC_PATIENTINVOICE_OBJECTID = '4110810';");
		
		
		ResultSet rs = ps.executeQuery();
		int nfact = 0;
		while(rs.next()) {
			nfact++;
			
			
			String uid_server = rs.getString("oc_patientinvoice_serverid")+"."+
						rs.getString("oc_patientinvoice_objectid");
			
						String uid = rs.getString("oc_patientinvoice_objectid");
			
						System.out.println(nfact + ") Numero facture: "+uid+" ----------------DEBUT DE TRAITEMENT DE L'ENVOIE---------------" );
						System.out.println("Periode ----------Du " + debut + " AU " + fin+ "---------------------" );
			
			JsonObject sent = null;
			try {
				sent = MedHub.SendInvoice(uid, MedHub.getToken(),false, facture_simple);
			
	          //if(sent!=null) {
			//String messagestatus = "ERROR";
			//System.out.println("Message back " + sent.toString());
			
			System.out.println("resultat apres envoie de la facture simple/consolidee " + sent);
			
			if(sent.getJsonObject("msg_body").getString("status").equalsIgnoreCase("SUCCESS")) {
				
				System.out.println("Status de la response apres envoie de la facture s/consolidee: "+uid_server+" envoye a med hub");
				Pointer.storePointer("MEDH.INV."+uid_server, uid_server);
				
			}else {
				
				Pointer.storePointer("MEDH.ERROR."+uid_server, sent.getJsonObject("msg_body").getString("status"));
				
				System.out.println("Status de la response apres envoie de la facture s/consolidee: "+uid_server+" La facture n'as pas ete envoyee!");
				System.out.println("Erreur " + sent.getJsonObject("msg_hd").getString("msg_status").toString());
				
				if(sent.getJsonObject("msg_hd").getString("msg_status").toString().contains("-50")) {
					
					Pointer.storePointer("MEDH.ERROR.USER."+uid_server, uid_server);
					
					/*
					 * if(!MedHub.CheckTempUsiSaved(uid_server,0)) {
					 * 
					 * System.out.println("Creer un patient");
					 * System.out.println("Resultat de la creation du patient" +
					 * MedHub.SendPatientToMfp(uid_server, MedHub.getToken()).toString());
					 * //Enregistrer l'Isu temporaire MedHub.SaveTempisu(uid_server,0); //et puis
					 * renvoyer la facture a l'aide de l'isu temporaire
					 * 
					 * 
					 * System.out.println("Envoie de la facture apres creation du patient " );
					 * 
					 * JsonObject sent2 = MedHub.SendInvoice(uid,
					 * MedHub.getToken(),true,facture_simple);
					 * 
					 * System.out.
					 * println("resultat de l'envoie de la facture apres creation du patient " +
					 * sent2.toString());
					 * 
					 * 
					 * if(sent2.getJsonObject("msg_body").getString("status").equalsIgnoreCase(
					 * "SUCCESS")){ System.out.println("Facture apres creation du patient"
					 * +uid_server+" envoye a med hub");
					 * Pointer.storePointer("MEDH.INV."+uid_server, uid_server); }else {
					 * System.out.println("Erreur d'envoie de la facture apres creation du patient"
					 * + sent2.getJsonObject("msg_body").toString()); }
					 * 
					 * }else { //renvoyer la facture a l'aide de l'isu temporaire
					 * //System.out.println("Envoie avec l'isu sauvegardee  " +
					 * MedHub.SendInvoice(uid, MedHub.getToken(),true,facture_simple).toString());
					 * 
					 * JsonObject sent3 = MedHub.SendInvoice(uid,
					 * MedHub.getToken(),true,facture_simple);
					 * 
					 * System.out.println("Envoie de la facture case 3 " + sent3);
					 * 
					 * if(sent3.getJsonObject("msg_body").getString("status").equalsIgnoreCase(
					 * "SUCCESS")){ System.out.println("Facture apres creation du patient "
					 * +uid_server+" envoye a med hub");
					 * Pointer.storePointer("MEDH.INV."+uid_server, uid_server); }else {
					 * System.out.println("Error apres creation du patient" +
					 * sent3.getJsonObject("msg_body").toString()); } }
					 */
					
				}else {
					if(sent.getJsonObject("msg_hd").getString("msg_status").toString().contains("-41")) {
						System.out.println("Facture dupliquee!");
						Pointer.storePointer("MEDH.INV."+uid_server, uid_server);
						Pointer.storePointer("MEDH.ERROR.DUP."+uid_server, uid_server);
					}else {
					System.out.println("Autre probleme!");
					Pointer.storePointer("MEDH.ERROR.OTHER."+uid_server, uid_server);
					}
				}	
			}
			System.out.println(" ---------------FIN DE TRAITEMENT DE L'ENVOIE-----------------" );
			
			} catch (ClientProtocolException e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
				System.out.println("Erreur " + e.getMessage());
			} catch (IOException e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
				System.out.println("Erreur " + e.getMessage());
			}
			
		}
		
		rs.close();
		ps.close();
		conn.close();
		
		System.exit(0);
	}

}
