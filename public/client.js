// coding: utf-8
jQuery(function ($) {
// $(function() {
  // OpenStreetMap
  function OpenStreetMapType() {

    OpenStreetMapType.prototype.tileSize = new google.maps.Size(256,256);
    OpenStreetMapType.prototype.minZoom = 4;
    OpenStreetMapType.prototype.maxZoom = 18;
    OpenStreetMapType.prototype.name = 'OSM';
    OpenStreetMapType.prototype.alt = 'OpenStreetMap';

    OpenStreetMapType.prototype.getTile = function( tileXY, zoom, ownerDocument ) {
      var tileImage = ownerDocument.createElement('img');
      
      var url= "http://tile.openstreetmap.org/" 
          + zoom.toString() + "/" + tileXY.x.toString() + "/" 
          + tileXY.y.toString() + ".png";

      tileImage.src = url;
      tileImage.style.width  = this.tileSize.width  + 'px';
      tileImage.style.height = this.tileSize.height + 'px';

      return tileImage;
    };
  }
  
  // GSI Map - Ortho
  function GSIOrthoMapType() {

    GSIOrthoMapType.prototype.tileSize = new google.maps.Size(256,256);
    GSIOrthoMapType.prototype.minZoom = 4;
    GSIOrthoMapType.prototype.maxZoom = 18;
    GSIOrthoMapType.prototype.name = 'GSI Ortho';
    GSIOrthoMapType.prototype.alt = '地理院地図 Ortho';

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
    GSIOldStdMapType.prototype.minZoom = 4;
    GSIOldStdMapType.prototype.maxZoom = 18;
    GSIOldStdMapType.prototype.name = 'GSI Standard 2012';
    GSIOldStdMapType.prototype.alt = '地理院地図 Standard 2012';

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
  function GSIStd2013MapType() {

    GSIStd2013MapType.prototype.tileSize = new google.maps.Size(256,256);
    GSIStd2013MapType.prototype.minZoom = 4;
    GSIStd2013MapType.prototype.maxZoom = 18;
    GSIStd2013MapType.prototype.name = 'GSI Standard 2013';
    GSIStd2013MapType.prototype.alt = '地理院地図 Standard 2013';

    GSIStd2013MapType.prototype.getTile = function( tileXY, zoom, ownerDocument ) {
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

  function OverlayControl(map, overlayMap) {
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

    // Setup "Overlay" control's click event listener
    google.maps.event.addDomListener( controlUI, 'click', function() {
      var currentMapTypeID = map.getMapTypeId();
      var overlayIndex = map.overlayMapTypes.getLength();
      if ( overlayIndex == 0 ) {
        map.overlayMapTypes.push( overlayMap );
      }
      else {
        map.overlayMapTypes.pop();
      }
      toggle_logo();
    });
    function toggle_logo() {
      $(denshiKokudoLOGO).toggle();
    }
  }

//   function LatLngMarker(map, center) {
//     var marker = new google.maps.Marker({
//       position: center,
//       title: "緯度／経度",
//       icon: "http://www.google.com/mapfiles/gadget/arrowSmall80.png",
//       draggable: true // ドラッグ可能にする
//     });
//     marker.setMap(map);

//     var text_div = document.createElement('div');
//     text_div.style.fontFamily = 'Arial,sans-serif';
//     text_div.style.fontSize = '12px';
//     text_div.style.paddingLeft = '4px';
//     text_div.style.paddingRight = '4px';
//     text_div.innerHTML = '緯度：' + center.lat() + '／' + '経度：' + center.lng();
//     map.controls[google.maps.ControlPosition.TOP_LEFT].push( text_div );

//     // マーカーのドロップ（ドラッグ終了）時のイベント
//     google.maps.event.addListener( marker, 'dragend', function(ev){
//       // イベントの引数evの、プロパティ.latLngが緯度経度。
//       text_div.innerHTML = '緯度：' + ev.latLng.lat() + '／' + '経度：' + ev.latLng.lng();
// //      map.controls[google.maps.ControlPosition.TOP_LEFT].push( text_div );
//     });
//   }


  var LatLngMarker = (function() {
    // constructor
    var LatLngMarker = function(map, center) {
      this.marker = new google.maps.Marker({
        position: center,
        title: "緯度／経度",
        icon: "http://www.google.com/mapfiles/gadget/arrowSmall80.png",
        draggable: true // ドラッグ可能にする
      });
      this.marker.setMap(map);
      text_div = document.createElement('div');
      text_div.style.fontFamily = 'Arial,sans-serif';
      text_div.style.fontSize = '12px';
      text_div.style.paddingLeft = '4px';
      text_div.style.paddingRight = '4px';
      text_div.innerHTML = '緯度：' + center.lat() + '／' + '経度：' + center.lng();
      map.controls[google.maps.ControlPosition.TOP_LEFT].push( text_div );
      
      // マーカーのドロップ（ドラッグ終了）時のイベント
      google.maps.event.addListener( this.marker, 'dragend', function(ev){
        // イベントの引数evの、プロパティ.latLngが緯度経度。
        text_div.innerHTML = '緯度：' + ev.latLng.lat() + '／' + '経度：' + ev.latLng.lng();
        //      map.controls[google.maps.ControlPosition.TOP_LEFT].push( text_div );
      });

    };
    var p = LatLngMarker.prototype;
    
    return LatLngMarker;
  })();

  infoWindow = new google.maps.InfoWindow();
  
  // position = new google.maps.LatLng
  var HistoryMarker = (function() {
    // constructor
    var HistoryMarker = function(option) {
      var self = this;
      this.map = option.map;
      this.latlng = new google.maps.LatLng(option.lat, option.lng);
      this.stn = option.stn;
      this.title = option.title;
      this.infos = new Array();
      this.infos.push(option.history);
      
      this.marker = new google.maps.Marker({
        position: this.latlng,
        title: this.title,
        icon: "http://labs.google.com/ridefinder/images/mm_20_blue.png",
        draggable: false, // ドラッグ不可
        animation: google.maps.Animation.DROP,
      });
      // 吹き出しを生成する
      this.infoWindow = new google.maps.InfoWindow({maxwitdh:300});
      this.infoWindow.setPosition(this.latlng);
      var content = this.get_info_contents();
      this.infoWindow.setContent(content);
      google.maps.event.addListener(this.marker, 'click', this.showTitle.bind(this));
    };
    
    var p = HistoryMarker.prototype;
    p.drop = function() {
      this.marker.setMap(this.map);
      // this.infoWindow.open(this.map, this.marker);
    };
    p.kill = function() {
      this.map = null;
      this.marker.setMap(null);
    };
    p.showTitle = function(event) {
      this.infoWindow.open(this.map, this.marker);
    };
    p.add_history = function(history) {
      this.infos.push(history);
      var content = this.get_info_contents();
      this.infoWindow.setContent(content);
    };
    p.same_position = function(lat, lng) {
      var latlng = new google.maps.LatLng(lat, lng);
      if ( latlng.lat() === this.latlng.lat() && latlng.lng() === this.latlng.lng() ) {
        return true;
      }
      return false;
    };
    p.get_info_contents = function() {
        var content = "";
        content += '<div class="info_window">';
        content += '<table style="font-size:xx-small;">';
        content += '<tbody>';
        for(var i = 0; i < this.infos.length; i++){
            content += this.infos[i];
        }
        content += '</tbody>';
        content += '</table>';
        content += '</div>';
        return content;
    };
    
    return HistoryMarker;
  })();

  var map;
  var center = new google.maps.LatLng(35.0390, 135.9210);
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
  var styledMap = new google.maps.StyledMapType(styles, {name: "Styled Google Map"});
  
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
      mapTypeIds: [
        google.maps.MapTypeId.ROADMAP, // 道路
        google.maps.MapTypeId.SATELLITE, // 航空写真
        google.maps.MapTypeId.HYBRID, // 航空写真＋主要道路
        google.maps.MapTypeId.TERRAIN, // 地形
        'map_style', // Google map カスタム
        'OSM', // Open Street map
        'GSI OldStd', // 地理院 2011
        'GSI Ortho' // 地理院 航空
      ],
      style: google.maps.MapTypeControlStyle.DROPDOWN_MENU,
      // style: google.maps.MapTypeControlStyle.HORIZONTAL_BAR, // google.maps.MapTypeControlStyle.DROPDOWN_MENU,
      // position: google.maps.ControlPosition.TOP_RIGHT
    }
  };
  var map_canvas = document.getElementById('map-canvas');
  map_canvas.style.width = '500px';
  map_canvas.style.height = '500px';
  map = new google.maps.Map(map_canvas, mapOptions);

  map.mapTypes.set('map_style', styledMap);
  map.setMapTypeId('map_style');

  var historyMarkers = new Array();
  var latlngMarker = new LatLngMarker(map, center);
  // 地図蔵版 http://japonyol.net/service-parking-area-michinoeki.html
  // var layer1 = new google.maps.FusionTablesLayer({
  //   query: {
  //     from: '186Nsf4x8WFwX8o7harkF6B7ROwKtOGwbZ3ktsMqZ'
  //   },
  // });
  // layer1.setMap(map);
  
  // Let's play with Google Maps Fusion-Table版(国土 http://www15.plala.or.jp/gonkunkan/main6.html
  // var layer2 = new google.maps.FusionTablesLayer({
  //   query: {
  //     // qselect: "col2\x3e\x3e1",
  //     // from: "1ZMrQjtiPTeGowOm2umjdUAP9993pk0Gypst2SJY",
  //     from: "1e42IO0JaA83mfjFTamr9Z1Mv-nhhQbmhYVN-G8K0",
  //     // where: ""
  //   },
  // });

  var layer2 = new google.maps.FusionTablesLayer({
    query: {
      select: 'geometry',
      from: "1GI6sSqRXx166Temd3ZqdicvA0i51JhaVw9E1O2wQ",
    },
    styles: [{
      where: "service_provider_type = '1'",
      polylineOptions: {
        strokeColor: "#0000ff",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
      }
    },{
      where: "service_provider_type = '2'",
      polylineOptions: {
        strokeColor: "#00ff00",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
      }
    },{
      where: "service_provider_type = '3'",
      polylineOptions: {
        strokeColor: "#ff0000",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
      }
    },{
      where: "service_provider_type = '4'",
      polylineOptions: {
        strokeColor: "#ff00ff",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
      }
    },{
      where: "service_provider_type = '5'",
      polylineOptions: {
        strokeColor: "#00ffff",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
      }
    }]
  });
  layer2.setMap(map);

  var OpenStreetMap = new OpenStreetMapType();
  var GSIOrthoMap   = new GSIOrthoMapType();
  var GSIOldStdMap  = new GSIOldStdMapType();
  var GSIStd2013OMap = new GSIStd2013MapType(); // オーバーレイ用の地図

  map.mapTypes.set( 'OSM', OpenStreetMap );
  map.mapTypes.set( 'GSI OldStd', GSIOldStdMap );
  map.mapTypes.set( 'GSI Ortho', GSIOrthoMap );
  
  var overlayControl = new OverlayControl( map, GSIStd2013OMap );
  
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
    
    // カード情報
    $('table.idm-ppm tbody').append('<th>' + contents.pasori_data.idm +'</th>');
    $('table.idm-ppm tbody').append('<th>' + contents.pasori_data.pmm +'</th>');
    
    // 履歴情報
    for(var index = 0; index < history.length; index++){
      var h = history[index];
      
      // リスト表示の情報
      var line = '';
      line += '<th>' + h.date_string +'</th>';
      line += '<th>' + h.ctype_name +'</th>';
      line += '<th>' + h.proc_name +'</th>';
      line += '<th>' + h.in_station_name +'</th>';
      line += '<th>' + h.out_station_name +'</th>';
      line += '<th>' + h.balance_string +'</th>';
      $('table.history tbody').append('<tr>'+ line + '</tr>');
      
      // 地図表示の情報
        var stations = new Array();
        // 入場駅の情報
        if (h.in_station_location != null) {
            var option = {};
            option.map = map;
            option.lat = h.in_station_location.lat;
            option.lng = h.in_station_location.lng;
            option.stn = h.in_station_name;
            option.title = h.in_company_name + "：" + h.in_station_name;
            option.history = "";
            option.history += '<tr>';
            option.history += '<td>' + h.date_string +'</td>';
            option.history += '<td>' + h.proc_name +'</td>';
            option.history += '<td>入場駅</td>';
            option.history += '</tr>';
            stations.push(option);
        }
        // 出場駅の情報
        if (h.out_station_location != null) {
            var option = {};
            option.map = map;
            option.lat = h.out_station_location.lat;
            option.lng = h.out_station_location.lng;
            option.stn = h.out_station_name;
            option.title = h.out_company_name + "：" + h.out_station_name;
            option.history = "";
            option.history += '<tr>';
            option.history += '<td>' + h.date_string +'</td>';
            option.history += '<td>' + h.proc_name +'</td>';
            option.history += '<td>出場駅</td>';
            option.history += '</tr>';
            stations.push(option);
        }
        
        for(var i = 0; i < stations.length; i++){
            var marker = null;
            // 経度、緯度が一致するMarkerが既に存在するかチェックする
            for(var j = 0; j < historyMarkers.length; j++){
                if( j in historyMarkers && historyMarkers[j].same_position(stations[i].lat, stations[i].lng) ) {
                    marker = historyMarkers[j];
                    break;
                };
            };
            // marker情報がなければ、追加する
            if (marker == null) {
                marker = new HistoryMarker(stations[i]);
                historyMarkers.push(marker);
            } else {
                // 履歴情報を追加する
                marker.add_history(stations[i].history);
            }
        }
      }
      
      // mapの表示範囲を変更する
      var minX = null;
      var minY = null;
      var maxX = null;
      var maxY = null;
      for(var i = 0; i < historyMarkers.length; i++){
          var lt = historyMarkers[i].marker.getPosition().lat();
          var lg = historyMarkers[i].marker.getPosition().lng();
          if (minX == null || lg <= minX){ minX = lg; }
          if (maxX == null || lg > maxX){ maxX = lg; }
          if (minY == null || lt <= minY){ minY = lt; }
          if (maxY == null || lt > maxY){ maxY = lt; }
      }
      var sw = new google.maps.LatLng(maxY, minX);
      var ne = new google.maps.LatLng(minY, maxX);
      var bounds = new google.maps.LatLngBounds(sw, ne);
      map.fitBounds(bounds);
      
      // Markerを表示する
      for(var i = 0; i < historyMarkers.length; i++){
          setTimeout(function(i) {
              historyMarkers[i].drop();
          }, i * 1000/historyMarkers.length, i );
      }
      
    // var message_li = document.createElement("li");
    // message_li.textContent = event.data;
    // document.getElementById("message_area").appendChild(message_li);
  }
  
  function clear(event){
    $('table.idm-ppm tbody *').remove();
    $('table.history tbody *').remove();

    for (i in historyMarkers) {
      historyMarkers[i].kill();
    }
    historyMarkers.length = 0;
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

