const {io} = require('../index');
const Bands = require('../models/bands');
const Band = require('../models/band');
const bands = new Bands();

bands.addBand( new Band('Queen') );
bands.addBand( new Band('Bon jovi') );
bands.addBand( new Band('Heroes del silencio') );
bands.addBand( new Band('Mago de oz') );

console.log(bands)

//mensajes de sockets
io.on('connection', client => {
    console.log('cliente conectado');

    client.emit('active-bands', bands.getBands());

    client.on('disconnect', () => { 
        console.log('cliente desconectado');
    });

    client.on('mensaje', ( payload) => {
        console.log('Mensaje', payload);
        io.emit('mensaje', {admin : 'nuevo mensaje'});
    });

    client.on('emitir-mensaje', (payload) => {
        //io.emit('nuevo-mensaje', payload); esto emite a todos los clientes conectados
        client.broadcast.emit('nuevo-mensaje', payload); //esto lo emite a todos los clientes menos al que lo emitio
    });

    client.on('vote-band', (payload) => {
        bands.voteBand(payload.id);
        io.emit('active-bands', bands.getBands());
    });

    client.on('add-band', (payload) => {
        const newBand = new Band(payload.name);
        bands.addBand(newBand);
        io.emit('active-bands', bands.getBands());
    });

    client.on('delete-band', (payload) => {
        bands.deleteBands(payload.id);
        io.emit('active-bands', bands.getBands());
    });
});