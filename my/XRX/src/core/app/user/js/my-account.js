/* Author: JBigalke */

$(document).ready(function(){
	var picarrowup = $('#Icons > #ein').css("height", "10px");	
	$(".inlinehead-text").prepend(picarrowup);	
});

/* Modified  Sourcecode from charter.js line 52 - 78 */
function showHideDiv(id)
{
	var xmlid = '#'+ id;
	var headid = xmlid + 'head';	
	$(xmlid).toggle( function(){});
	$(headid+'> .inlinehead-text > #ein').toggleClass('rotate');
	$(headid+'> .inlinehead-text > #ein').toggleClass('ic');
}

