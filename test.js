var Docker = require('dockerode')
var docker2 = new Docker({ host: '10.94.2.224', port: 2375 })
docker2
  .run('hello-world', ['bash', '-c', 'uname -a'], process.stdout)
  .then(function (data) {
    var output = data[0]
    var container = data[1]
    console.log(output.StatusCode)
    return container.remove()
  })
  .then(function (data) {
    console.log('container removed')
  })
  .catch(function (err) {
    console.log(err)
  })
