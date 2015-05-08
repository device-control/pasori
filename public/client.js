// coding: utf-8
jQuery(function ($) {
// $(function() {
    // GSI Map - Ortho
  function GSIOrthoMapType() {

    GSIOrthoMapType.prototype.tileSize = new google.maps.Size(256,256);
    GSIOrthoMapType.prototype.minZoom = 15;
    GSIOrthoMapType.prototype.maxZoom = 17;
    GSIOrthoMapType.prototype.name = 'GSI Ortho';
    GSIOrthoMapType.prototype.alt = 'Chirin Map Ortho';

    GSIOrthoMapType.prototype.getTile = function( tileXY, zoom, ownerDocument ) {
      var tileImage = ownerDocument.createElement('img');
      
      var url= "http://cyberjapandata.gsi.go.jp/xyz/ort/" 
            + zoom.toString() + "/" + tileXY.x.toString() + "/" 
            + tileXY.y.toString() + ".jpg";

      tileImage.src = url;
      tileImage.style.width  = this.tileSize.width  + 'px';
      tileImage.style.height = this.tileSize.height + 'px';

      return tileImage;
    };
  }

  // Chiriin Map Standard 2013
  function GSIOldStdMapType() {

    GSIOldStdMapType.prototype.tileSize = new google.maps.Size(256,256);
    GSIOldStdMapType.prototype.minZoom = 15;
    GSIOldStdMapType.prototype.maxZoom = 17;
    GSIOldStdMapType.prototype.name = 'GSI Standard 2012';
    GSIOldStdMapType.prototype.alt = 'Chiriin Standard 2012';

    GSIOldStdMapType.prototype.getTile = function( tileXY, zoom, ownerDocument ) {
      var tileImage = ownerDocument.createElement('img');

      var url= "http://cyberjapandata.gsi.go.jp/xyz/std2012/" 
            + zoom.toString() + "/" + tileXY.x.toString() + "/" 
            + tileXY.y.toString() + ".png";

      tileImage.src = url;
      tileImage.style.width  = this.tileSize.width  + 'px';
      tileImage.style.height = this.tileSize.height + 'px';
      
      return tileImage;
    };
  }

  // Chiriin Map Standard 2013 (Overlay)
  function GSIStd2013OverlayedMapType() {

    GSIStd2013OverlayedMapType.prototype.tileSize = new google.maps.Size(256,256);
    GSIStd2013OverlayedMapType.prototype.minZoom = 15;
    GSIStd2013OverlayedMapType.prototype.maxZoom = 17;
    GSIStd2013OverlayedMapType.prototype.name = 'GSI Std 2013 (Overlay)';
    GSIStd2013OverlayedMapType.prototype.alt = 'Chiriin Map Standard 2013 (Overlay)';

    GSIStd2013OverlayedMapType.prototype.getTile = function( tileXY, zoom, ownerDocument ) {
      var tileImage = ownerDocument.createElement('img');

      var url= "http://cyberjapandata.gsi.go.jp/xyz/std/" 
            + zoom.toString() + "/" + tileXY.x.toString() + "/" 
            + tileXY.y.toString() + ".png";

      tileImage.src = url;
      tileImage.style.width  = this.tileSize.width  + 'px';
      tileImage.style.height = this.tileSize.height + 'px';
      
      tileImage.style.opacity = 0.4; // <=== Set Opacity

      return tileImage;
    };
  }

  function OverlayControl(map) {
    // Denshi Kokudo LOGO 
    denshiKokudoLOGO = document.createElement('div');
    denshiKokudoLOGO.innerHTML =
      "<a href='http://portal.cyberjapan.jp/' target='_blank'>" + 
      "<img src='http://cyberjapan.jp/images/icon01.gif' width='32' height='32' alt='Denshi Kokudo'></a>";
    denshiKokudoLOGO.style.display = "none";
    map.controls[ google.maps.ControlPosition.RIGHT_BOTTOM].push( denshiKokudoLOGO );
    
    var controlDiv = document.createElement( 'div' );
    controlDiv.style.padding = '5px';
    // Set CSS for the control border
    var controlUI = document.createElement('div');
    controlUI.style.backgroundColor = 'white';
    controlUI.style.borderStyle = 'solid';
    controlUI.style.borderWidth = '2px';
    controlUI.style.cursor = 'pointer';
    controlUI.style.textAlign = 'center';
    controlUI.title = 'Click to overlay contours';
    controlDiv.appendChild( controlUI );

    // Set CSS for the control interior
    var controlText = document.createElement('div');
    controlText.style.fontFamily = 'Arial,sans-serif';
    controlText.style.fontSize = '12px';
    controlText.style.paddingLeft = '4px';
    controlText.style.paddingRight = '4px';
    controlText.innerHTML = '<b>Overlay</b>';
    controlUI.appendChild(controlText);

    map.controls[google.maps.ControlPosition.TOP_RIGHT].push( controlDiv );

    var GSIStd2013Overlay = new GSIStd2013OverlayedMapType();

    // Setup "Overlay" control's click event listener
    google.maps.event.addDomListener( controlUI, 'click', function() {
      var currentMapTypeID = map.getMapTypeId();
      var overlayIndex = map.overlayMapTypes.getLength();
      if ( overlayIndex == 0 ) {
        map.overlayMapTypes.push( GSIStd2013Overlay );
//        denshiKokudoLOGO.style.display = "inline";
      }
      else {
        map.overlayMapTypes.pop();
//        denshiKokudoLOGO.style.display = "none";
      }
      toggle_logo();
    });
    function toggle_logo() {
      $(denshiKokudoLOGO).toggle();
    }
  }


  // var DenshiKokudoLOGO = null;
  // var gMap;
  // var zoomLevel = 16;
  // var mapCenter = new google.maps.LatLng( 35.541896, 139.250157 );




  var map;
  var center = new google.maps.LatLng(35.00904999253169, 135.91976173437504);
  // Create an array of styles.
  var styles = [
    {
      stylers: [
        { hue: "#00ffe6" },
        { saturation: -20 }
      ]
    },{
      featureType: "road",
      elementType: "geometry",
      stylers: [
        { lightness: 100 },
        { visibility: "simplified" }
      ]
    },{
      featureType: "road",
      elementType: "labels",
      stylers: [
        { visibility: "off" }
      ]
    }
  ];
  var styledMap = new google.maps.StyledMapType(styles, {name: "Styled Map"});
  
  var mapOptions = {
    zoom: 12,
    minZoom: 4, //
    maxZoom: 18, // 国土地理院
    center: center,
    zoomControl: true,
    zoomControlOptions: {
      style: google.maps.ZoomControlStyle.LARGE,
      position: google.maps.ControlPosition.LEFT_TOP
    },
    streetViewControl: true,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    mapTypeControl: true,
    mapTypeControlOptions: {
      mapTypeIds: [google.maps.MapTypeId.ROADMAP, 'map_style', 'GSI OldStd', 'GSI Ortho'],
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
    }
  };
  var map_canvas = document.getElementById('map-canvas');
  map_canvas.style.width = '500px';
  map_canvas.style.height = '500px';
  map = new google.maps.Map(map_canvas, mapOptions);

  map.mapTypes.set('map_style', styledMap);
  map.setMapTypeId('map_style');

  // 地図蔵版 http://japonyol.net/service-parking-area-michinoeki.html
  // var layer1 = new google.maps.FusionTablesLayer({
  //   query: {
  //     from: '186Nsf4x8WFwX8o7harkF6B7ROwKtOGwbZ3ktsMqZ'
  //   },
  // });
  // layer1.setMap(map);
  
  // Let's play with Google Maps Fusion-Table版(国土 http://www15.plala.or.jp/gonkunkan/main6.html
  var layer2 = new google.maps.FusionTablesLayer({
    query: {
      // qselect: "col2\x3e\x3e1",
      from: "1ZMrQjtiPTeGowOm2umjdUAP9993pk0Gypst2SJY",
      // where: ""
    },
  });
  layer2.setMap(map);

  var GSIOrthoMap   = new GSIOrthoMapType();
  var GSIOldStdMap  = new GSIOldStdMapType();

  map.mapTypes.set( 'GSI OldStd', GSIOldStdMap );
  map.mapTypes.set( 'GSI Ortho', GSIOrthoMap );
  
  var overlayControl = new OverlayControl( map );
  
  google.maps.event.addListener( map, 'maptypeid_changed', function() {
    var currentMapTypeID = map.getMapTypeId();
    // hide "streetViewControl"
    if ( currentMapTypeID == google.maps.MapTypeId.ROADMAP ) {
      map.setOptions( {'streetViewControl': true} );
    } else {
      map.setOptions( {'streetViewControl': false} );
    }
  });
  
  
  var ws = null;
  // 接続
  function open() {
    if (ws == null) {
      // WebSocket の初期化
      address = $('input.pasori-address').val();
      // TODO: address のフォーマットチェックが必要...
      ws = new WebSocket("ws://" + address);
      // イベントハンドラの設定
      ws.onopen = onOpen;
      ws.onmessage = onMessage;
      ws.onclose = onClose;
      ws.onerror = onError;
      $("label.status").text("接続中...");
    }
  }
  
  function onOpen(event) {
    console.log("接続した");
    $("label.status").text("接続");
  }
  function onClose(event) {
    console.log("切断した");
    $("label.status").text("切断");
    ws = null;
  }
  function onError(event) {
    console.log("エラー発生");
    $("label.status").text("エラー発生");
    
    var message_li = document.createElement("li");
    message_li.textContent = "エラー発生"
    document.getElementById("message_area").appendChild(message_li);
  }
  
  function onMessage(event){
    console.log("メッセージ受信");
    var json = JSON.parse(event.data);
    var contents = json.contents;
    var history = contents.pasori_data.history;
    $('table.idm-ppm tbody').append('<th>' + contents.pasori_data.idm +'</th>');
    $('table.idm-ppm tbody').append('<th>' + contents.pasori_data.pmm +'</th>');
    var index = 0;
    var max = history.length;
    for(index = 0; index < max; index++){
      
      var line = '<th>' + history[index].ctype +'</th>';
      line += '<th>' + history[index].ctype_name +'</th>';
      line += '<th>' + history[index].proc + '</th>';
      line += '<th>' + history[index].proc_name + '</th>';
      line += '<th>' + history[index].date + '</th>';
      line += '<th>' + history[index].date_string + '</th>';
      line += '<th>' + history[index].time + '</th>';
      line += '<th>' + history[index].time_string + '</th>';
      line += '<th>' + history[index].balance + '</th>';
      line += '<th>' + history[index].region + '</th>';
      line += '<th>' + history[index].seq + '</th>';
      line += '<th>' + history[index].in_line + '</th>';
      line += '<th>' + history[index].in_sta + '</th>';
      line += '<th>' + history[index].out_line + '</th>';
      line += '<th>' + history[index].out_sta + '</th>';
      $('table.history tbody').append('<tr>'+ line + '</tr>');
    }
    
    // var message_li = document.createElement("li");
    // message_li.textContent = event.data;
    // document.getElementById("message_area").appendChild(message_li);
  }
  
  function clear(event){
    $('table.idm-ppm tbody *').remove();
    $('table.history tbody *').remove();
  }
  
  // メッセージ送信時の処理
  // document.getElementById("read").onclick = function(){
  $("input.read").click(function(){
    // var comment = document.getElementById("comment").value;
    // document.getElementById("comment").value = '';
    $(clear);
    ws.send("read");
  });
  
  // 接続
  $("input.connect").click( function(){
    $(open);
  });
  
  // 切断
  $("input.disconnect").click( function(){
    if (ws != null) {
      ws.close;
    }
  });
  
  // クリア
  //document.getElementById("clear").onclick = function(){
  $("input.clear").click(function(){
    $(clear);
    // $('table.idm-ppm tbody *').remove();
    // $('table.history tbody *').remove();
  });
  
  // $(open);
});

