const Election = artifacts.require('Elections');

contract("Elections", accounts => {
    it('Should initialize an Election successfully.', (done) => {
        const instance = Election.deployed();
        const elecId = instance.initializeElection.call("Test", "Who is your favorite person?")
        if (elecId){
            done();
        } else {
            done("ridim");
        }
    });
});