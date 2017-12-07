$(document).ready( function(){



	
	$("#getArchivesButton").click(function(){
		
		$.ajax({
			url: ("/mom/service/geolocations-archives"),
			method: 'GET',
			dataType: 'json',
			success: function (data){
				console.log(data);
			}

		});

	});
});
	



function test(){

	var entry = $("#feedinput").val();
	var beispielurl = "/mom/service/geolocations-charters$feed="+entry;
	$("#urlspan").text(beispielurl)
	$.ajax({
		url: ("/mom/service/geolocations-charters"),
		method: 'GET',
		data: {feed: entry},
		dataType: 'json',
		success: function (data){
			console.log(data);
		}	
	});
}
