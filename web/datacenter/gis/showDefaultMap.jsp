<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<script src="https://unpkg.com/@google/markerclustererplus@4.0.1/dist/markerclustererplus.min.js"></script>
<script src="https://maps.googleapis.com/maps/api/js?key=<%=SH.cs("GoogleAPIKey","")%>"></script>
<div id="map-canvas" style='width: 100%;height: 95%'></div>

<script>
	function initialize() {
	  var center = new google.maps.LatLng(13, 19);
	  var mapOptions = {
	    zoom: 2,
	    center: center,
	    mapTypeId: google.maps.MapTypeId.TERRAIN
	  };

	  map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
	  for (i = 0; i < markers1.length; i++) {
	    addMarker(markers1[i]);
	  }
	  markerCluster = new MarkerClusterer(map, gmarkers1, {
	    imagePath: 'https://cdn.rawgit.com/googlemaps/v3-utility-library/master/markerclustererplus/images/m'
	  });
	}
	/**
	 * Function to add marker to map
	 */
	function addMarker(marker) {
	  var category = marker[4];
	  var title = marker[1];
	  var pos = new google.maps.LatLng(marker[2], marker[3]);
	  var content = marker[1];

	  marker1 = new google.maps.Marker({
	    title: title,
	    position: pos,
	    category: category,
	    map: map
	  });

	  gmarkers1.push(marker1);

	  // Marker click listener
	  google.maps.event.addListener(marker1, 'click', (function(marker1, content) {
	    return function() {
	      infowindow.setContent(content);
	      infowindow.open(map, marker1);
	      map.panTo(this.getPosition());
	      //map.setZoom(15);
	    }
	  })(marker1, content));
	}

	/**
	 * Function to filter markers by category
	 */
	filterMarkers = function(category) {
	  var newmarkers = [];
	  for (i = 0; i < markers1.length; i++) {
	    marker = gmarkers1[i];
	    // If is same category or category not picked
	    if (marker.category == category || category.length === 0) {
	      newmarkers.push(marker);
	    }
	  }
	  markerCluster.clearMarkers();
	  markerCluster.addMarkers(newmarkers);
	}
	google.maps.event.addDomListener(window, "load", initialize);

	var gmarkers1 = [];
	var markers1 = [];
	var infowindow = new google.maps.InfoWindow({
	  content: ''
	});
	var markerCluster;

	// Our markers
	markers1 = [
	<%
		int n=0;
    	Connection conn = SH.getStatsConnection();
    	PreparedStatement ps = conn.prepareStatement("select distinct dc_monitorserver_name,dc_monitorserver_latitude,dc_monitorserver_longitude from dc_monitorservers,dc_monitorvalues where dc_monitorserver_serverid=dc_monitorvalue_serverid and dc_monitorvalue_date>? and dc_monitorserver_latitude is not null and dc_monitorserver_longitude is not null");
		ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()-MedwanQuery.getInstance().getConfigInt("gbhPublicInactivityPeriodInMonths",3)*60*SH.getTimeDay()));
    	ResultSet rs = ps.executeQuery();
    	while(rs.next()){
    		if(n>0){
    			out.print(",");
    		}
    		out.println("['"+n+++"','"+SH.c(rs.getString("dc_monitorserver_name")).replaceAll("'","&apos;")+"',"+rs.getString("dc_monitorserver_latitude")+","+rs.getString("dc_monitorserver_longitude")+",'OpenClinic']");
    	}
    	rs.close();
    	ps.close();
    	conn.close();
    %>
	];
</script>