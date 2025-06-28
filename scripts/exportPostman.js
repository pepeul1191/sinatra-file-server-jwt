require('dotenv').config();
const axios = require('axios');
const fs = require('fs');

const API_KEY = process.env.POSTMAN_API_KEY;
const COLLECTION_NAME = process.env.POSTMAN_COLLECTION_NAME;
const OUTPUT_DIR = './requests';

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR);
}

async function exportCollection() {
  try {
    // Obtener todas las colecciones
    const collectionsResponse = await axios.get('https://api.getpostman.com/collections', {
      headers: { 'X-Api-Key': API_KEY }
    });

    // Buscar la colección por nombre
    const collection = collectionsResponse.data.collections.find(
      col => col.name === COLLECTION_NAME
    );

    if (!collection) {
      throw new Error(`Colección "${COLLECTION_NAME}" no encontrada`);
    }

    // Obtener la colección completa
    const collectionResponse = await axios.get(
      `https://api.getpostman.com/collections/${collection.uid}`,
      { headers: { 'X-Api-Key': API_KEY } }
    );

    // Guardar en archivo
    const outputPath = `${OUTPUT_DIR}/${COLLECTION_NAME}.postman.json`;
    fs.writeFileSync(outputPath, JSON.stringify(collectionResponse.data.collection, null, 2));

    console.log(`Colección exportada a ${outputPath}`);
  } catch (error) {
    console.error('Error al exportar:', error.message);
    process.exit(1);
  }
}

exportCollection();