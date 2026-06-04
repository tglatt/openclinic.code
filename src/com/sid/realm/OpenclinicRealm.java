package com.sid.realm;

import java.util.List;
import org.apache.catalina.realm.*;

import be.openclinic.system.SH;

import java.util.ArrayList;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.sql.PreparedStatement;
import java.sql.Connection;
import javax.naming.Context;
import java.security.MessageDigest;
import javax.sql.DataSource;
import javax.naming.InitialContext;
import java.security.Principal;

public class OpenclinicRealm extends RealmBase
{
    private String username;
    private String password;
    
    public Principal authenticate(final String username, final String credentials) {
        this.username = username;
        this.password = credentials;
        try {
            boolean bOk = false;
            final Context ctx = new InitialContext();
            final DataSource dsAdmin = (DataSource)ctx.lookup("java:comp/env/admin");
            final Connection conn = dsAdmin.getConnection();
            int userid = -1;
            try {
                userid = Integer.parseInt(username);
            }
            catch (Exception ie) {
                final PreparedStatement ps = conn.prepareStatement("SELECT a.userid FROM Users a, Userparameters b WHERE a.userid=b.userid and b.parameter='alias' and value = ? ");
                ps.setString(1, username);
                final ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    userid = rs.getInt("userid");
                }
            }
            final PreparedStatement ps2 = conn.prepareStatement("select * from users where userid=?");
            System.out.println("1");
            ps2.setInt(1, userid);
            System.out.println("2");
            final ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) {
                System.out.println("3");
                final MessageDigest md = MessageDigest.getInstance("SHA-1");
                byte[] hash = md.digest(this.password.getBytes());
                bOk = MessageDigest.isEqual(hash, rs2.getBytes("encryptedPassword"));
                if(!bOk) {
                    System.out.println("4");
                	hash=BCrypt.hashpw(this.password, BCrypt.gensalt((userid+rs2.getString("personid")+new SimpleDateFormat("dd/MM/yyyy").format(rs2.getDate("start"))).hashCode()+"")).getBytes();
                    bOk = MessageDigest.isEqual(hash, rs2.getBytes("encryptedPassword"));
                }
                System.out.println("5");
            }
            rs2.close();
            ps2.close();
            conn.close();
            System.out.println("6");

            if (bOk) {
                System.out.println("7");
                return this.getPrincipal(username);
            }
        }
        catch (Exception e1) {
            e1.printStackTrace();
        }
        return null;
    }
    
    protected String getName() {
        return this.username;
    }
    
    protected String getPassword(final String username) {
        return this.password;
    }
    
    protected Principal getPrincipal(final String string) {
        final List<String> roles = new ArrayList<String>();
        roles.add("FHIRUser");
        final Principal principal = (Principal)new GenericPrincipal(this.username, this.password, (List)roles);
        return principal;
    }
}
