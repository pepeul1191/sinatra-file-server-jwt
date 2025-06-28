const axios = require('axios');
const fs = require('fs');
require('dotenv').config();

const API_KEY = process.env.POSTMAN_API_KEY;
const WORKSPACE_ID = process.env.POSTMAN_WORKSPACE_ID;
const OUTPUT_DIR = './requests';
const FILE_NAME = 'Files-Ruby-Sinatra.postman.json'; // Nombre exacto de tu archivo

async function restoreCollection() {
  try {
    const inputPath = `${OUTPUT_DIR}/${FILE_NAME}`;
    console.log(`📦 Restaurando desde archivo: ${inputPath}`);
    
    const fileContent = fs.readFileSync(inputPath, 'utf8');
    const data = JSON.parse(fileContent);
    
    // Determinar si es colección o entorno
    if (data.info && data.info.schema) {
      // Es una colección
      const response = await axios.post('https://api.getpostman.com/collections', 
        { collection: data },
        {
          headers: { 
            'X-Api-Key': API_KEY,
            'Content-Type': 'application/json'
          },
          params: { workspace: WORKSPACE_ID }
        }
      );
      console.log('✅ Colección restaurada con ID:', response.data.collection.id);
    } else if (data.values !== undefined) {
      // Es un entorno
      const response = await axios.post('https://api.getpostman.com/environments', 
        { environment: data },
        {
          headers: { 
            'X-Api-Key': API_KEY,
            'Content-Type': 'application/json'
          },
          params: { workspace: WORKSPACE_ID }
        }
      );
      console.log('✅ Entorno restaurado con ID:', response.data.environment.id);
    } else {
      throw new Error('El archivo no es una colección ni entorno válido de Postman');
    }
  } catch (error) {
    console.error('❌ Error al restaurar:');
    console.error(error.response?.data || error.message);
    if (error.response) {
      console.error('Detalles:', error.response.data);
    }
    process.exit(1);
  }
}

// Ejecutar
(async () => {
  try {
    await restoreCollection();
    console.log('🎉 Proceso completado exitosamente!');
  } catch (error) {
    console.error('🔥 Error final:', error.message);
  }
})();