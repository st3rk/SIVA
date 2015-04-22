def build_page(dir, title, workout)
	File.open(dir + '/index.html', 'w') do |index|
	index << "<!DOCTYPE html>

<html lang=\"fr\">
  <head>
    <meta charset=\"UTF-8\">
    <title>#{title}</title>

		<!--my CSS-->
    <link rel=\"stylesheet\" href=\"../css/style.css\" type=\"text/css\" media=\"all\" />

		<!--leaflet-->
		<link rel=\"stylesheet\" href=\"http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.css\" />
		<script src=\"http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.js\"></script>

		<!--set the red marker-->
		<script>
			var redIcon = L.icon({
				iconUrl: '../images/marker-icon-red.png',
				shadowUrl: '../images/marker-shadow.png',

				iconSize:     [27, 41], // size of the icon
				shadowSize:   [25, 41], // size of the shadow
				iconAnchor:   [12, 41], // point of the icon which will correspond to marker's location
				shadowAnchor: [4, 62],  // the same for the shadow
				popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
			});
		</script>

		<!--import flot data-->
		<script src=\"data_array.js\" type=\"text/javascript\"></script>
		<!--flot-->
		<script type=\"text/javascript\" src=\"../js/flot/jquery.js\"></script>
		<script type=\"text/javascript\" src=\"../js/flot/jquery.flot.js\"></script>
		<script type=\"text/javascript\" src=\"../js/flot/jquery.flot.time.js\"></script>
		<script type=\"text/javascript\" src=\"../js/flot/jquery.flot.crosshair.js\"></script>

		<script type=\"text/javascript\">
			$(function () {
				plot = $.plot($(\"#speed\"), [speed_array], { series: { lines: { show: true }, color: \"#2a6aff\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });

				plot2 = $.plot($(\"#heart_rate\"), [hr_array], { series: { lines: { show: true }, color: \"#FF2A2C\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });
				
				plot3 = $.plot($(\"#altitude\"), [alt_array], { series: { lines: { show: true }, color: \"#663399\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });

				plot4 = $.plot($(\"#cadence\"), [cadence_array], { series: { lines: { show: true }, color: \"#2eef34\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });

				plot5 = $.plot($(\"#temperature\"), [temp_array], { series: { lines: { show: true }, color: \"#FF9900\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });

				plot6 = $.plot($(\"#stance\"), [stance_array], { series: { lines: { show: true }, color: \"#ADFF2F\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });

				plot7 = $.plot($(\"#vertical_osc\"), [vertical_osc_array], { series: { lines: { show: true }, color: \"#FF0080\" }, crosshair: { mode: \"x\" }, grid: { hoverable: true, autoHighlight: false }, xaxis:{ mode: \"time\"} });


				$(\"#speed\").bind(\"plothover\",  function (event, pos, item) {        
					plot2.setCrosshair({x: pos.x})
					plot3.setCrosshair({x: pos.x})
					plot4.setCrosshair({x: pos.x})
					plot5.setCrosshair({x: pos.x})
					plot6.setCrosshair({x: pos.x})
					plot7.setCrosshair({x: pos.x})
				});
				$(\"#heart_rate\").bind(\"plothover\",  function (event, pos, item) {        
					plot.setCrosshair({x: pos.x})
					plot3.setCrosshair({x: pos.x})
					plot4.setCrosshair({x: pos.x})
					plot5.setCrosshair({x: pos.x})
					plot6.setCrosshair({x: pos.x})
					plot7.setCrosshair({x: pos.x})
				});
				$(\"#altitude\").bind(\"plothover\",  function (event, pos, item) {        
					plot.setCrosshair({x: pos.x})
					plot2.setCrosshair({x: pos.x})
					plot4.setCrosshair({x: pos.x})
					plot5.setCrosshair({x: pos.x})
					plot6.setCrosshair({x: pos.x})
					plot7.setCrosshair({x: pos.x})
				});
				$(\"#cadence\").bind(\"plothover\",  function (event, pos, item) {        
					plot.setCrosshair({x: pos.x})
					plot2.setCrosshair({x: pos.x})
					plot3.setCrosshair({x: pos.x})
					plot5.setCrosshair({x: pos.x})
					plot6.setCrosshair({x: pos.x})
					plot7.setCrosshair({x: pos.x})
				});
				$(\"#temperature\").bind(\"plothover\",  function (event, pos, item) {        
					plot.setCrosshair({x: pos.x})
					plot2.setCrosshair({x: pos.x})
					plot3.setCrosshair({x: pos.x})
					plot4.setCrosshair({x: pos.x})
					plot6.setCrosshair({x: pos.x})
					plot7.setCrosshair({x: pos.x})
				});
				$(\"#temperature\").bind(\"plothover\",  function (event, pos, item) {        
					plot.setCrosshair({x: pos.x})
					plot2.setCrosshair({x: pos.x})
					plot3.setCrosshair({x: pos.x})
					plot4.setCrosshair({x: pos.x})
					plot5.setCrosshair({x: pos.x})
					plot7.setCrosshair({x: pos.x})
				});
				$(\"#vertical_osc\").bind(\"plothover\",  function (event, pos, item) {        
					plot.setCrosshair({x: pos.x})
					plot2.setCrosshair({x: pos.x})
					plot3.setCrosshair({x: pos.x})
					plot4.setCrosshair({x: pos.x})
					plot5.setCrosshair({x: pos.x})
					plot6.setCrosshair({x: pos.x})
				});
			});
		</script>

		<!-- import js variables -->
		<script src=\"geojson_track.js\" type=\"text/javascript\"></script>

	</head>
	<body>
	<div id=\"content\">
		<div style=\"width:900px; height:600px\" id=\"map\"></div>
		<script>
			var map = L.map('map').setView([51.505, -0.09], 13);
			L.tileLayer('https://{s}.tiles.mapbox.com/v4/st3rk.lp1a6dgh/{z}/{x}/{y}.png?access_token=pk.eyJ1Ijoic3QzcmsiLCJhIjoiSU1GcFk2QSJ9.Ik_ALL-BsiMCBAyad5kHzA', {
				attribution: 'Map data &copy; <a href=\"http://openstreetmap.org\">OpenStreetMap</a> contributors, <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA</a>, Imagery © <a href=\"http://mapbox.com\">Mapbox</a>',
					maxZoom: 18
			}).addTo(map);
			L.geoJson(track, {
				style: {
					\"color\": \"#ff7800\",
					\"weight\": 2,
					\"opacity\": 0.65
				}
			}).addTo(map);

			map.fitBounds(pos_array);
			start_point.addTo(map);
			end_point.addTo(map);
			L.marker([48.8969655521214, 2.090679919347167], {icon: redIcon}).addTo(map);
		</script>
		<div class=\"data-container\">
			<div class=\"data\">
				<div class=\"data_name\">Temps total :</div>
				<div class=\"data_value\">#{workout.total_time}</div>
			</div>
			<div class=\"data\">
				<div class=\"data_name\">Temps couru :</div>
				<div class=\"data_value\">#{workout.moving_time}</div>
			</div>
			<div class=\"data\">
				<div class=\"data_name\">Distance totale :</div>
				<div class=\"data_value\">#{workout.total_distance} km</div>
			</div>
			<div class=\"data\">
				<div class=\"data_name\">Vitesse moy. :</div>
				<div class=\"data_value\">#{workout.avg_speed} km</div>
			</div>
		</div>
		<div class=\"graphe-container\">
			<h1>Vitesse (km/h)</h1>
			<div id=\"speed\" class=\"graphe-placeholder\"></div>
			<h1>Cardio (bpm)</h1>
			<div id=\"heart_rate\" class=\"graphe-placeholder\"></div>
			<h1>Altitude (m)</h1>
			<div id=\"altitude\" class=\"graphe-placeholder\"></div>
			<h1>Cadence</h1>
			<div id=\"cadence\" class=\"graphe-placeholder\"></div>
			<h1>Température (°C)</h1>
			<div id=\"temperature\" class=\"graphe-placeholder\"></div>
			<h1>Stance</h1>
			<div id=\"stance\" class=\"graphe-placeholder\"></div>
			<h1>Oscillation Verticale</h1>
			<div id=\"vertical_osc\" class=\"graphe-placeholder\"></div>
		</div>
		</div>
	</body>
</html>"
	end
end
