const fs = require('fs')
const fetchJson = (filePath) =>JSON.parse(fs.readFileSync(filePath).toString())

module.exports = async function() {
    const conf = fetchJson('./exporter.json')
    const {url, filename} = conf
    const data = fs.readFileSync(`./${filename}`).toString()
    const fakeData = [ { fake: 'data' } ];
    return await axios.post(url, {
       data: Data
    });    
}
