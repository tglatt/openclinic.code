package be.openclinic.llrp;

import java.io.IOException;
import java.io.StringWriter;

import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamWriter;

import org.llrp.modules.LlrpModule;

import net.enilink.llrp4j.LlrpContext;
import net.enilink.llrp4j.net.LlrpClient;
import net.enilink.llrp4j.net.LlrpEndpoint;
import net.enilink.llrp4j.types.LlrpMessage;

public class Llrp {
	
	LlrpContext ctx = LlrpContext.create(new LlrpModule());
	LlrpClient client =null;
	
	LlrpEndpoint endpoint = new LlrpEndpoint() {
	  @Override
	  public void messageReceived(LlrpMessage message) {
		System.out.println("Message!");
	    StringWriter writer = new StringWriter();
	    try {
	      XMLStreamWriter xmlWriter = XMLOutputFactory.newInstance().createXMLStreamWriter(writer);
	      ctx.createXmlEncoder(true).encodeMessage(message, xmlWriter);
	      String xml = writer.toString();
	      System.out.println("RECEIVED:\n" + xml);
	    } catch (Exception e) {
	      e.printStackTrace();
	    }
	  }
	
	  @Override
	  public void errorOccured(String message, Throwable cause) {
		  cause.getMessage();
	  }
	};
	
	public void start() throws InterruptedException, IOException {
		client = LlrpClient.create(ctx, "127.0.0.1").endpoint(endpoint);
		System.out.println("Connection started");
	}
	
	public void stop() throws IOException {
		client.close();
		System.out.println("Connection stopped");
	}
	
	public void transact(LlrpMessage message) throws IOException, InterruptedException {
		client.transact(message);
	}
	
	public void send(LlrpMessage message) throws IOException, InterruptedException {
		client.send(message);
	}
}
