const fs = require('fs')
const axios = require('axios')
const csv=require('csvtojson')
const fetchJson = (filePath) =>JSON.parse(fs.readFileSync(filePath).toString())
const getEntry = ({ORD,FIELD,VALUE,DEF}) => {
    const def = parseInt(DEF)
        /***************
        legend:
        case(DEF)
        1: { before + quotes no comma
        2: } after + quotes
        3: [ after
        4: ] after + quotes
        5: no quotes
        6: ] after
        7: { before
        ***************/    
    const Q1 = [1,7].includes(def) ? '{' : ''
    const Q2 = [2,6].includes(def) ? '},' : ''
    const Q3 = def === 3 ? '[' : ''
    const Q4 = def === 4 ? '],' : ''
    const QUOTE = [3,5,6,7].includes(def) ? '' : '"'
    const COMMA = def > 1 ? '' : ','
    const PAIR =  FIELD > ''  ?  `"${FIELD}":${QUOTE}${VALUE}${QUOTE}${COMMA}` : ''
    return `${Q1}${PAIR}${Q2}${Q3}${Q4}`; 
}

module.exports = async function() {
    const conf = fetchJson('./exporter.json')
    const {url, file} = conf
    const data = fs.readFileSync(`./${file}`).toString().replace(/\t/g, ',')
    const headers = ['ORD','FIELD','VALUE','DEF']
    const converter = csv({
      noheader: true,
      headers: headers,
    });    
    try {
        const [,...entries] =  await converter.fromString(data)
        const jsonString = `[${entries.map(entry => getEntry(entry)).reduce((o,s)=> o+s,'')}]`.replace(/,]/g, ']').replace(/,}/g, '}')
        axios.post(url, {
            data: jsonString
         });        
    }catch(e){
        console.log(e)
    }       
}

