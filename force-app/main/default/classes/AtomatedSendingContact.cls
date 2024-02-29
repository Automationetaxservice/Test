public without sharing class AtomatedSendingContact{

    //invocable method
        @InvocableMethod
        public static List <String> sendEnvelope(List<Contact> record) {
            Contact mySource = record.get(0);
            sendEnvelopeInFuture(mySource.Id);
           return Null;
        }

        //call method
        @future(callout = true)
        public static void sendEnvelopeInFuture(Id mySourceId) {
            sendEnvelopeandReturn(mySourceId);
        }
        public static Id sendEnvelopeAndReturn(Id mySourceId){
            dfsle.Envelope myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(
                new dfsle.Entity(mySourceId)
            );

            Contact myContact = [SELECT Name, Email FROM Contact Where Id = :mySourceId WITH SECURITY_ENFORCED LIMIT 1];
   
            dfsle.Recipient myRecipient = dfsle.Recipient.fromSource(
                myContact.Name,
                myContact.Email,
                null,
                'Signer1', 
                new dfsle.Entity(myContact.Id)
            );
            myEnvelope = myEnvelope.withRecipients(new List<dfsle.Recipient> { myRecipient });
            dfsle.UUID myTemplatedId = dfsle.UUID.parse('8a96f60f-7465-4983-965f-7a6a10762251');
            dfsle.Document myDocument = dfsle.Document.fromTemplate(
                myTemplatedId,
                'Form 1040'
            );
            myEnvelope = myEnvelope.withDocuments(
                new List<dfsle.Document> { myDocument }
            );
            myEnvelope = dfsle.EnvelopeService.sendEnvelope(
                myEnvelope,
                true
            );
            return myEnvelope.id;
        }
}