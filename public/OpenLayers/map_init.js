        var map;

	function clone(obj){
	    if(obj == null || typeof(obj) != 'object')
		return obj;
	    var temp = {};
	    for(var key in obj)
		temp[key] = clone(obj[key]);
	    return temp;
	}

        function initmap(){
		OpenLayers.INCHES_PER_UNIT['cm'] = OpenLayers.INCHES_PER_UNIT['m'] / 100.0;

		// disable mouse wheel zoom
		OpenLayers.Handler.MouseWheel = OpenLayers.Class(OpenLayers.Handler);

		// patch to allow russian chars in url:

		OpenLayers.Util.getParameters = function(url) {
		    // if no url specified, take it from the location bar
		    url = url || window.location.href;

		    //parse out parameters portion of url string
		    var paramsString = "";
		    if (OpenLayers.String.contains(url, '?')) {
			var start = url.indexOf('?') + 1;
			var end = OpenLayers.String.contains(url, "#") ?
				    url.indexOf('#') : url.length;
			paramsString = url.substring(start, end);
		    }

		    var parameters = {};
		    var pairs = paramsString.split(/[&;]/);
		    for(var i=0, len=pairs.length; i<len; ++i) {
			var keyValue = pairs[i].split('=');
			if (keyValue[0]) {
			    var key = decodeURIComponent(keyValue[0]);
			    var value = keyValue[1] || ''; //empty string if no value

			    //decode individual values
			    value = value.split(",");
			    for(var j=0, jlen=value.length; j<jlen; j++) {
				try{
					value[j] = decodeURIComponent(value[j]);
				} catch(err) {
					// got rus chars, just skip for now
					value[j] = '';
				}
			    }

			    //if there's only one value, do not return as array                    
			    if (value.length == 1) {
				value = value[0];
			    }

			    parameters[key] = value;
			 }
		     }
		    return parameters;
		};


	    OpenLayers.Projection.addTransform('z1','z2', function(point){
	    //	point.x /= 1;
	    //	point.y /= -1;
	    	point.x /= 100;
	    	point.y /= -100;
	    	return point;
	    });

            map = new OpenLayers.Map('map', 
	    	{
		    tileSize: new OpenLayers.Size(512,512),
		    maxExtent: new OpenLayers.Bounds(9969, -1743726, 2029869, -10364),
		    maxResolution: '2000',
		    units: 'cm',
		    projection: new OpenLayers.Projection('z1'),
		    displayProjection: new OpenLayers.Projection('z2'),
		    numZoomLevels: 7/*,
	 	    controls: [
                    	new OpenLayers.Control.PanZoom(),
		        new OpenLayers.Control.LayerSwitcher(),
		        new OpenLayers.Control.MousePosition({numDigits: 1}),
		        new OpenLayers.Control.ScaleLine()
		    ]*/
		}
	    );
	    map.addControl( new OpenLayers.Control.LayerSwitcher() );
	    map.addControl( new OpenLayers.Control.MousePosition({numDigits: 1}) );
	    map.addControl( new OpenLayers.Control.ScaleLine() );


	    var layer_2gis_gif = new OpenLayers.Layer.TileCache("2gis gif",
                "http://62.165.61.1:8080", 'tiles', {gutter: 2, format: 'image/gif'});

	    var layer_2gis_gif_bw = new OpenLayers.Layer.TileCache("2gis gif bw",
                "http://62.165.61.1:8080", 'tiles/bw', {gutter: 2, format: 'image/gif'});

	    var layer_2gis_png = new OpenLayers.Layer.TileCache("2gis png",
                "http://62.165.61.1:8080", 'tiles', {gutter: 2});

	    var layer1 = new OpenLayers.Layer.WMS("WMS Layer",
                "http://zed.orbitel.ru/map/1.php", {layers: 'basic'}, {gutter: 0});

	    var layer2 = new OpenLayers.Layer.TileCache("TileCache Layer",
                "http://zed.orbitel.ru/map/1.php", '');

	    var style_params = {
		    //externalGraphic: "http://62.165.61.1:8080/tiles/img/marker-gold.png",
		    externalGraphic: "http://62.165.61.1:8080/tiles/img/1user.png",
                    pointRadius: 10
	    };
            var style = new OpenLayers.Style(style_params);


            var sel_users_layer = new OpenLayers.Layer.Vector(
                "selected users",
                {
                    	styleMap: new OpenLayers.StyleMap({
				"default": style,
				"select": {
				    fillColor: "#8aeeef",
				    strokeColor: "#32a8a9"
				}
			})
                }
            );

	    map.sel_users_layer = sel_users_layer;

	    sel_users_layer.events.on({
		    'featureselected': onFeatureSelect,
		    'featureunselected': onFeatureUnselect
	    });

	    //var control = new OpenLayers.Control.SelectFeature(sel_users_layer);
	    //map.addControl(control);
	    //control.activate();

	    function onPopupClose(evt) {
	        // 'this' is the popup.
	        selectControl.unselect(this.feature);
	    }

	    function onFeatureSelect(evt) {
		    feature = evt.feature;
		    popup = new OpenLayers.Popup.FramedCloud(null,
					     feature.geometry.getBounds().getCenterLonLat(),
					     null,
					     "&nbsp;" + feature.attributes.title,
					     null, true, onPopupClose);
		    feature.popup = popup;
		    popup.autoSize = true;
		    popup.minSize = new OpenLayers.Size(100,80);
		    popup.feature = feature;
		    map.addPopup(popup);
	    }

	    function onFeatureUnselect(evt) {
		    feature = evt.feature;
		    if (feature.popup) {
			popup.feature = null;
			map.removePopup(feature.popup);
			feature.popup.destroy();
			feature.popup = null;
		    }
	    }

	    function points2features(a_points_coords, a_points_counts, a_titles){
		    var points = [],cp,c;
		    var styles = [],s,i;
		    if(!a_titles){
		    	a_titles = [];
		    }
		    for(i=0; i<a_points_coords.length; i++){
			cp = a_points_coords[i];
			c  = a_points_counts[i];
			if(c>1){
				if(!(s=styles[c])){
					s = styles[c] = clone(style_params);
					s.pointRadius += s.pointRadius*c*0.08;
				}
				points.push(
				    new OpenLayers.Feature.Vector(
					new OpenLayers.Geometry.Point(cp[0],-cp[1]),
					{'title':a_titles[i]},
					s
				    )
				);
			} else {
				points.push(
				    new OpenLayers.Feature.Vector(
					new OpenLayers.Geometry.Point(cp[0],-cp[1]),
					{'title':a_titles[i]}
				    )
				);
			}
		    }
		    return points;
	    }

            map.addLayers([
	    	layer_2gis_gif_bw,
	    	layer_2gis_gif,
		layer_2gis_png,
		layer1,
		layer2,
		sel_users_layer
            ]);

	    if( typeof(points_coords) != 'undefined' ){
		    var all_users_layer = new OpenLayers.Layer.Vector(
			"all users",
			{
				visibility: false,
				styleMap: new OpenLayers.StyleMap({
					"default": style,
					"select": {
					    fillColor: "#8aeeef",
					    strokeColor: "#32a8a9"
					}
				})
			}
		    );
		    all_users_layer.addFeatures(points2features(points_coords, points_counts));
		    map.addLayer(all_users_layer);
	    }

           map.setCenter(new OpenLayers.LonLat(1240036, -983184),3);

	   // custom funcz

	   map.show_ips = function(ips){
		var points = [];
		var h_coords = {};
		var a_coords = [];
		var a_counts = [];
		var i,cp,count;
		for(i=0;i<ips.length;i++){
			if( cp = ips2coords[ips[i]]) {
				if(h_coords[cp])
					h_coords[cp]++;
				else {
					h_coords[cp]=1;
					a_coords.push(cp);
				}
			}
		}
		var bounds = bounds = new OpenLayers.Bounds();
		for(i=0;i<a_coords.length;i++){
			cp = a_coords[i];
			a_counts[i] = h_coords[cp];
			bounds.extend(new OpenLayers.LonLat(cp[0],-cp[1]));
		}
		sel_users_layer.addFeatures(points2features(a_coords,a_counts));
		this.zoomToExtent(bounds);
		if(this.getZoom() > 4){
			this.zoomTo(4);
		}
	   }

	   map.show_addrs = function(addrs){
		var points = [];
		var h_coords = {};
		var a_coords = [];
		var a_counts = [];
		var a_titles = [];
		var i,cp,count;
		for(i=0;i<addrs.length;i++){
			if( cp = addrs2coords[addrs[i]]) {
				if(h_coords[cp])
					h_coords[cp]++;
				else {
					h_coords[cp]=1;
					a_coords.push(cp);
					a_titles.push(addrs[i]);
				}
			}
		}
		var bounds = bounds = new OpenLayers.Bounds();
		for(i=0;i<a_coords.length;i++){
			cp = a_coords[i];
			a_counts[i] = h_coords[cp];
			bounds.extend(new OpenLayers.LonLat(cp[0],-cp[1]));
		}
		sel_users_layer.addFeatures(points2features(a_coords,a_counts,a_titles));
		this.zoomToExtent(bounds);
		if(this.getZoom() > 4){
			this.zoomTo(4);
		}
	   }

        }

