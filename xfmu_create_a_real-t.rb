require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'httparty'

configure do
  set :bind, '0.0.0.0'
  set :port, 4567
end

before do
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => 'GET, POST, OPTIONS, PUT, DELETE',
          'Access-Control-Allow-Headers' => 'Content-Type, Accept, Accept-Language, Accept-Encoding'
end

options '*' do
  response.headers['Allow'] = 'HEAD, GET, POST, PUT, DELETE, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  halt 200
end

get '/' do
  erb :index
end

get '/api/data' do
  # API endpoint to fetch real-time data from an external source
  response = HTTParty.get('https://api.example.com/data')
  JSON.pretty_generate(response.parsed_response)
end

post '/api/data' do
  # API endpoint to send data to an external source
  data = JSON.parse(request.body.read)
  response = HTTParty.post('https://api.example.com/data', body: data.to_json, headers: { 'Content-Type' => 'application/json' })
  JSON.pretty_generate(response.parsed_response)
end

__END__

@@ index
<html>
  <head>
    <title>Real-Time Web App Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.4/dist/Chart.min.js"></script>
  </head>
  <body>
    <canvas id="chart" width="400" height="200"></canvas>
    <script>
      const ctx = document.getElementById('chart').getContext('2d');
      const chart = new Chart(ctx, {
        type: 'line',
        data: [],
        options: {
          scales: {
            y: {
              beginAtZero: true
            }
          }
        }
      });

      // Fetch data from API endpoint
      fetch('/api/data')
        .then(response => response.json())
        .then(data => {
          chart.data.labels = data.map(item => item.label);
          chart.data.datasets[0].data = data.map(item => item.value);
          chart.update();
        });

      // Update chart in real-time
      setInterval(() => {
        fetch('/api/data')
          .then(response => response.json())
          .then(data => {
            chart.data.labels = data.map(item => item.label);
            chart.data.datasets[0].data = data.map(item => item.value);
            chart.update();
          });
      }, 1000);
    </script>
  </body>
</html>