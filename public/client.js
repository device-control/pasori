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

  var HistoryMarkerArray = (function() {
    // constructor
    var HistoryMarkerArray = function(option) {
      this.markers = new Array();
    };
    
    var p = HistoryMarkerArray.prototype;
    p.addMarker = function(option) {
      var marker = null;
      // 経度、緯度が一致するMarkerが既に存在するかチェックする
      for(var i = 0; i < this.markers.length; i++){
        if( this.markers[i].isSamePosition(option.lat, option.lng) ) {
          marker = this.markers[i];
          break;
        };
      };
      // marker情報がなければ、追加する
      if (marker == null) {
        marker = new HistoryMarker(option);
        this.markers.push(marker);
      } else {
        // 履歴情報を追加する
        marker.addInfo(option.info);
      }
    };
    p.getMarkerIndex = function(lat, lng) {
      var index = null;
      for(var i = 0; i < this.markers.length; i++){
        if ( this.markers[i].isSamePosition(lat, lng) ) {
          index = i;
        }
      }
      return index;
    };
    p.getBounds = function() {
      var bounds = new google.maps.LatLngBounds();
      for(var i = 0; i < this.markers.length; i++){
        bounds.extend( this.markers[i].latLng );
      }
      return bounds;
    };
    p.show = function() {
      len = this.markers.length;
      for(var i = 0; i < len; i++){
        setTimeout(function( marker ) {
          marker.drop();
        }, i * 1000/len, this.markers[i] );
      }
    };
    p.clear = function() {
      for(var i = 0; i < this.markers.length; i++){
        this.markers[i].kill();
      }
      this.markers.length = 0;
    };
    p.stop = function() {
      for(var i = 0; i < this.markers.length; i++){
        this.markers[i].stop();
      }
    };
    p.animation = function() {
      for(var i = 0; i < this.markers.length; i++){
        this.markers[i].animation();
      }
    };
    
    return HistoryMarkerArray;
  })();

  var HistoryMarker = (function() {
    // constructor
    var HistoryMarker = function(option) {
      this.map = option.map;
      this.latLng = new google.maps.LatLng(option.lat, option.lng);
      this.stationName = option.stationName;
      this.title = option.title;
      this.infos = new Array();
      this.infos.push(option.info);
      this.is_bounce = false;
      
      this.marker = new google.maps.Marker({
        position: this.latLng,
        title: this.title,
        icon: "http://labs.google.com/ridefinder/images/mm_20_blue.png",
        draggable: false, // ドラッグ不可
        animation: google.maps.Animation.DROP,
      });
      // 吹き出しを生成する
      this.infoWindow = new google.maps.InfoWindow();
      this.infoWindow.setPosition(this.latLng);
      var content = this.getInfoWindowContents();
      this.infoWindow.setContent(content);
      google.maps.event.addListener(this.marker, 'click', this.showTitle.bind(this));
      google.maps.event.addListener(this.marker, 'animation_changed', this.animation.bind(this));
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
      this.infoWindow.setZIndex(0);
      this.infoWindow.open(this.map, this.marker);
    };
    p.animation = function(event) {
      if ( this.is_bounce ) {
        if ( this.marker.getAnimation() == null ) {
          this.marker.setAnimation(google.maps.Animation.BOUNCE);
        }
      } else {
        if ( this.marker.getAnimation() != null ) {
          this.marker.setAnimation(null);
        }
      }
    };
    p.bounce = function() {
      this.is_bounce = true;
    };
    p.stop = function() {
      this.is_bounce = false;
    };
    p.addInfo = function(info) {
      this.infos.push(info);
      var content = this.getInfoWindowContents();
      this.infoWindow.setContent(content);
    };
    p.isSamePosition = function(lat, lng) {
      var latlng = new google.maps.LatLng(lat, lng);
      if ( latlng.lat() === this.latLng.lat() && latlng.lng() === this.latLng.lng() ) {
        return true;
      }
      return false;
    };
    p.getInfoWindowContents = function() {
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
  map.setMapTypeId('OSM');

  var historyMarkers = new HistoryMarkerArray();
  var latlngMarker = new LatLngMarker(map, center);

  var layer2 = new google.maps.FusionTablesLayer({
    query: {
      select: 'geometry',
      from: "1oVouXsjBueThIMExCZh9LhYNVINnqIjzrnuc1fIT",
      // where: "name CONTAINS '線'", // "線"を含むもののみ
      // where: "data_type = 'rail'", // 路線だけ
      // where: "data_type = 'station'", // 駅だけ
    },
    styles: [{
      where: "service_provider_type = '1'",
      polylineOptions: {
        strokeColor: "#0000ff",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
        zIndex: 1,
      },
      markerOptions: {
        iconName: 'small_blue',
        zIndex: 2,
      }
    },{
      where: "service_provider_type = '2'",
      polylineOptions: {
        strokeColor: "#00ff00",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
        zIndex: 1,
      },
      markerOptions: {
        iconName: 'small_green',
        zIndex: 2,
      }
    },{
      where: "service_provider_type = '3'",
      polylineOptions: {
        strokeColor: "#ff0000",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
        zIndex: 1,
      },
      markerOptions: {
        iconName: 'small_red',
        zIndex: 2,
      }
    },{
      where: "service_provider_type = '4'",
      polylineOptions: {
        strokeColor: "#ff00ff",
        strokeOpacity: 1.0,
        // strokeWeight: "2" 
        zIndex: 1,
      },
      markerOptions: {
        iconName: 'small_purple',
        zIndex: 2,
      }
    },{
      where: "service_provider_type = '5'",
      polylineOptions: {
        strokeColor: "#ffff00",
        strokeOpacity: 1.0,
        // strokeWeight: "2"
        zIndex: 1,
      },
      markerOptions: {
        iconName: 'small_yellow',
        zIndex: 2,
      }
    }]
  });
  layer2.setMap(map);
  google.maps.event.addListener(layer2, 'click', function(e) {
    // Change the content of the InfoWindow
    e.infoWindowHtml =
      '事業者：' + e.row['company_name'].value + "<br>" +
      '路線：' + e.row['line_name'].value;
    if( e.row['data_type'].value == 'station') {
      e.infoWindowHtml += '<br>駅名：' + e.row['station_name'].value;
    }
  });
  
  //
  // Google Maps APIの「お天気＆雲レイヤ」と「Panoramioレイヤ」は2015年に廃止されるそうです。
  //  http://shimz.me/blog/google-map-api/3556
  // 天気情報をだしたいなら「Leaflet.jsで作成した地図上にお天気情報をオーバーレイする」を参考になるかも
  //  http://shimz.me/blog/map/3671
  // そもそも地図を表示する方法としてはgoogle map apiを利用しなくても"OpenLayers"や"Leaflet" js library を利用して表示できる。
  // 参考サイトは「地理院地図の地図タイルを使ったD3.js&Cesiumサンプル」がいいかもしれない
  //  http://shimz.me/blog/d3-js/3134
  //
  
  // 天気／雲レイヤを表示させたい場合、以下のように&libraries=weatherを指定する必要がある
  //  <script src="http://maps.googleapis.com/maps/api/js?sensor=false&region=JP&libraries=weather"></script>
  //
  // // 天気レイヤ追加
  // var weatherLayer = new google.maps.weather.WeatherLayer(); 
  // weatherLayer.setMap(map);
  
  // //雲レイヤ追加
  // var cloudLayer = new google.maps.weather.CloudLayer(); 
  // cloudLayer.setMap(map);

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
    var histories = contents.pasori_data.histories;
    
    // カード情報
    $('table.idm-ppm tbody').append('<th>' + contents.pasori_data.idm +'</th>');
    $('table.idm-ppm tbody').append('<th>' + contents.pasori_data.pmm +'</th>');
    
    // 履歴情報
    for(var index = 0; index < histories.length; index++){
      var h = histories[index];
      var in_marker_index = null;
      var out_marker_index = null;
      
      // 地図表示の情報
      // 入場駅の情報
      if (h.in_station_location != null && h.in_station_info != null) {
        var option = {};
        option.map = map;
        option.lat = h.in_station_location.lat;
        option.lng = h.in_station_location.lng;
        option.stn = h.in_station_info.station_name;
        option.title = h.in_station_info.company + "：" + h.in_station_info.station_name;
        option.info = makeMarkerInfo( h.date_string, h.proc_name, "入場駅" );
        historyMarkers.addMarker(option);
        in_marker_index = historyMarkers.getMarkerIndex( option.lat, option.lng );
      }
      // 出場駅の情報
      if (h.out_station_location != null && h.out_station_info != null) {
        var option = {};
        option.map = map;
        option.lat = h.out_station_location.lat;
        option.lng = h.out_station_location.lng;
        option.stn = h.out_station_info.station_name;
        option.title = h.out_station_info.company + "：" + h.out_station_info.station_name;
        option.info = makeMarkerInfo( h.date_string, h.proc_name, "出場駅" );
        historyMarkers.addMarker(option);
        out_marker_index = historyMarkers.getMarkerIndex( option.lat, option.lng );
        
      }
      
      // リスト表示の情報
      var line = '';
      line += '<th class="date_string">' + h.date_string +'</th>';
      line += '<th>' + h.ctype_name +'</th>';
      line += '<th>' + h.proc_name +'</th>';
      var in_station_name = null;
      if (h.in_station_info != null) {
        in_station_name = h.in_station_info.station_name;
      }
      line += '<th class="in_station_name" data-marker='+ in_marker_index + '>' + in_station_name +'</th>';
      var out_station_name = null;
      if (h.out_station_info != null) {
        out_station_name = h.out_station_info.station_name;
      }
      line += '<th class="out_station_name" data-marker='+ out_marker_index + '>' + out_station_name +'</th>';

      line += '<th>' + h.balance_string +'</th>';
      $('table.history tbody').append('<tr>'+ line + '</tr>');
      
    }
    
    // mapの表示範囲をmarkerすべてが表示できるように変更する
    if ( historyMarkers.markers.length ) {
      map.fitBounds( historyMarkers.getBounds() );
    }
    
    // Markerを表示する
    historyMarkers.show();
    
  }

  function makeMarkerInfo( date, proc, inOut ) {
    var info = "";
    info += '<tr>';
    info += '<td>' + date +'</td>';
    info += '<td>' + proc +'</td>';
    info += '<td>' + inOut + '</td>';
    info += '</tr>';
    return info;
  }

  function clear(event){
    $('table.idm-ppm tbody *').remove();
    $('table.history tbody *').remove();
    
    historyMarkers.clear();
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
  
  // 日付
  $("table.history").on('click', '.date_string', function(event){
    var line = $(event.target.closest("tr"));
    var in_index = line.find(".in_station_name").data().marker;
    if ( in_index === 'null' ) { in_index = null };
    var out_index = line.find(".out_station_name").data().marker;
    if ( out_index === 'null' ) { out_index = null };
    
    historyMarkers.stop();
    
    if ( in_index != null || out_index != null ) {
      var bounds = new google.maps.LatLngBounds();
      
      if ( in_index != null) {
        var marker = historyMarkers.markers[in_index];
        bounds.extend( marker.latLng );
        marker.bounce();
      }
      if ( out_index != null) {
        var marker = historyMarkers.markers[out_index];
        bounds.extend( marker.latLng );
        marker.bounce();
      }
      map.panToBounds(bounds);
    }
    
    historyMarkers.animation();
  });
  
  // 入場駅
  $("table.history").on('click', '.in_station_name', function(event){
    var index = event.target.dataset.marker;
    if ( index === 'null' ) { index = null };
    
    historyMarkers.stop();
    
    if ( index != null ) {
      var marker = historyMarkers.markers[index];
      map.panTo( marker.latLng );
      marker.bounce();
    }
    
    historyMarkers.animation();
  });
  
  // 出場駅
  $("table.history").on('click', '.out_station_name', function(event){
    var index = event.target.dataset.marker;
    if ( index === 'null' ) { index = null };
    
    historyMarkers.stop();
    
    if ( index != null ) {
      var marker = historyMarkers.markers[index];
      map.panTo( marker.latLng );
      marker.bounce();
    }
    
    historyMarkers.animation();
  });
  
});

