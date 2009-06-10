// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function make_clickable_rows(){
	$$('tr.clickable').each(function(tr){
		var url = tr.getAttribute('url');
		if(!url) return;
		$A(tr.children).each(function(td){
			if( td.tagName == 'TD' && td.children.length == 0 ){
				Event.observe(td,'click',function(el){
					window.location = url;
				});
			}
		});
	});
}
