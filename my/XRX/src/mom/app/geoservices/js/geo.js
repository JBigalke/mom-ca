$(document).ready( function(){

/*
$.ajax({
	url: ("/mom/service/geolocations"),
	method: 'GET',
	dataType: 'json',
	success: function (data){
		console.log(data.geolocations[0].location);
		$('#jsoncontainer').append(data.geolocations[0].location.name);
	}

});

*/
	
	$("#getArchivesButton").click(function(){
		
		$.ajax({
			url: ("/mom/service/archives"),
			method: 'GET',
			dataType: 'json',
			success: function (data){
				console.log(data);
			}

		});

	});
});
	




