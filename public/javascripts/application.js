// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function make_clickable_rows(){
	$$('tr.clickable').each(function(tr){
		var url = tr.getAttribute('url');
		if(!url) return;
		$A(tr.children).each(function(td){
			if( td.tagName == 'TD' && td.innerHTML.indexOf('<a') == -1 ){
				Event.observe(td,'click',function(el){
					window.location = url;
				});
			}
		});
	});
}

var main_add_menu;
var search_box;

function toggle_search(){
  if( !search_box ){
    search_box = $('search-box');
    $("search-q").observe('keydown',function(ev){
      if( ev.keyCode == 27 ) search_box.hide();
    })
  }

  if( search_box.visible() ){
    search_box.hide();
  } else {
    search_box.show();
    $("search-q").focus();
  }
}

function show_additional_settings(ev){
	var fake_ev = {stop:function(){}};
	if(ev){
		ev.stop();
		fake_ev.clientX = ev.clientX;
		fake_ev.clientY = ev.clientY;
	} else {
		var offset  = $('add-settings-toggler').positionedOffset();
		fake_ev.clientX = offset[0] + 5;
		fake_ev.clientY = offset[1] + 5;
	}

	if( ! main_add_menu ){
		var main_add_menu_items = [
                  {
                    name:      'Календарь',
                    className: 'calendar',
                    href:      '/calendar'
                  },{
                    name:      'Ночные дежурства',
                    className: 'nights',
                    href:      '/nights'
                  }
                ];

		var ck = readCookie('can_manage');

		$H({ 
			customers:'Абоненты', 
			houses:'Дома', 
			users:'Пользователи CRM' 
		}).each(function(i){
			if( ck.indexOf(i[0][0]) != -1 ){
				main_add_menu_items.push({
					name: i[1],
					className: i[0],
					href: '/' + i[0]
				});
			}
		});

		main_add_menu = new Proto.Menu({
			selector:  '#add-settings-toggler',
			className: 'jsmenu desktop zzz',
			menuItems: main_add_menu_items
		});
	}

	main_add_menu.show(fake_ev);
}

function readCookie(name) {
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for(var i=0;i < ca.length;i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1,c.length);
        if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
    }
    return null;
}


