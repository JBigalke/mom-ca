$(document).ready(function(){
	var picarrowup = $('#Icons > #ein').css("height", "10px");	
	$(".inlinehead-text").prepend(picarrowup);	
	createTwitterTimeline();

});

function createRequestFriendshipPopup(name, uid){
	
	var dialogdiv = "<div id='request-friendship-popup'>Ask "+name+" to become your friend?</div>";
	$("#popup-container").append(dialogdiv);
	$("#request-friendship-popup").dialog({
        resizable: false,
        width: 300,
        modal: true,
        buttons: {
            Cancel: function() {
              $(this).dialog("close");
            },
            "Yes": function(){
            	RequestFriendship(uid);
            	$(this).dialog("close");
            }
          }
	});	
}

function createConfirmFriendshipPopup(name, uid){	
	var dialogdiv = "<div id='confirm-friendship-popup'>Add "+name+" to your friends?</div>";
	$("#confirm-popup-container").append(dialogdiv);
	$("#confirm-friendship-popup").dialog({
        resizable: false,
        width: 300,
        modal: true,
        buttons: {
            Cancel: function() {
              $(this).dialog("close");
            },
            "Yes": function(){
            	confirmFriendship(uid);
            	$(this).dialog("close");
            }
          }
	});	
}

function createIgnoreFriendshipPopup(name, uid){	
	var dialogdiv = "<div id='ignore-friendship-popup'>Ignore "+name+"?</div>";
	$("#confirm-popup-container").append(dialogdiv);
	$("#ignore-friendship-popup").dialog({
        resizable: false,
        width: 300,
        modal: true,
        buttons: {
            Cancel: function() {
              $(this).dialog("close");
            },
            "Yes": function(){
            	IgnoreFriendship(uid);
            	$(this).dialog("close");
            }
          }
	});	
}

function confirmFriendship(uid){
	   var content = uid;
	    $.ajax({
	    	url: ("/mom/service/confirmFriendship"),
	    	contentType: "application/xml",
	    	type: "POST",
	    	data: content,
	    	complete: function(data, textStatus, jqXHR) {
	    		alert("Successfull");
         	   location.reload();

	    		}
	    });  	
}

function RequestFriendship(uid){	
    var content = uid;
    	    $.ajax({
      url: ("/mom/service/requestFriendship"),
      contentType: "application/xml",
      type: "POST",
      data: content,
      complete: function(data, textStatus, jqXHR) {
    	  alert("Successfull");
    	   location.reload();

      }
    });  
}

function IgnoreFriendship(uid){	
    var content = uid;
    	    $.ajax({
      url: ("/mom/service/ignoreFriendship"),
      contentType: "application/xml",
      type: "POST",
      data: content,
      complete: function(data, textStatus, jqXHR) {
    	  alert("Successfull");
      }
    });  
}


function createTwitterTimeline(){
 var twittername = $("#Twitter-Timeline-Container > a").attr('id');
	twttr.widgets.createTimeline({
		  sourceType: "profile",
		  screenName: twittername,
		  width: 	  "312",
		  height:	  "500"		 
		}, document.getElementById("Twitter-Timeline-Container"))


}


/* Modified  Sourcecode from charter.js line 52 - 78 */
function showHideDiv(id)
{
	var xmlid = '#'+ id;
	var headid = xmlid + 'head';	
	$(xmlid).toggle( function(){});
	$(headid+'> .inlinehead-text > #ein').toggleClass('rotate');
	$(headid+'> .inlinehead-text > #ein').toggleClass('ic');
}
