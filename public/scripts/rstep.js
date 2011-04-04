$(document).ready(function(){
	$(document).keydown(function(evt){
		if(evt.shiftKey) $('#add').val('Add Project (+)');
	});
	$(document).keyup(function(evt){
		if(!evt.shiftKey) $('#add').val('Add Project');
		if(evt.keyCode===187) {
			addRow();
		}
		if(evt.keyCode===189) {
			deleteRow();
		}
	});
	$('#add').click(addRow);
});

function addRow() {
	var row = $('#formrow').clone();
	$('input[type="text"]',row).val('');
	$('input[type="password"]',row).val('');
	row.attr('id','');
	$('#formbody').append(row);
}

function deleteRow() {
	var rows = $('#formbody tr');
	if(rows.length > 1) {
		$(rows[rows.length-1]).remove();
	}
	
}