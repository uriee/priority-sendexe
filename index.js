const fs = require('fs')
const axios = require('axios')
const fetchJson = (filePath) =>JSON.parse(fs.readFileSync(filePath).toString())

module.exports = async function() {
    const conf = fetchJson('./exporter.json')
    const {url, file} = conf
    const data = fs.readFileSync(`./${file}`).toString()
    await axios.post(url, {
       data: JSON.stringify(data)
    });    
}
