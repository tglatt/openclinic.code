<script>
  window.addEventListener('message', function(event) {
    alert("Message received from the child: " + event.data); // Message received from child
  });
</script>
<iframe id='myframe' src='https://webrtc.hnrw.org:448/testMessage2.html'/>