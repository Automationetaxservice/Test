public class AlluraClass implements Queueable {    
    public Id opportunityId;    
    public Id oppDocId;    
    public List<dfsle.Recipient> myRecipients;    
    public List<OpportunityContactRole> oppContactRoles;    
    public List<Opportunity> oppOwner;    
    public List<dfsle.Document> documents;    
    public dfsle.Envelope myEnvelope;        
    public void AlluraClass(String id) {        
        this.opportunityId = id;        
        this.myRecipients = new List<dfsle.Recipient>();   
     }
    // Uses Apex Toolkit's Envelope Service to Send the Envelope (after it's built). 
    public void execute(QueueableContext context) { 
        this.getOppOwner(); 
        this.getOppDocumentId(); 
        this.buildRecipients(); 
        this.buildEnvelope(); 
        dfsle.EnvelopeService.sendEnvelope(this.myEnvelope, true); 
    }
    public void getOppOwner() { 
        this.oppOwner = [SELECT Owner.Name, Owner.Email, Owner.Id FROM Opportunity o WHERE o.Id =: this.opportunityId]; 
    }
    public void getOppDocumentId() { 
        List<ContentDocumentLink> oppDocs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: this.opportunityId]; 
        Id oppDoc = oppDocs[0].ContentDocumentId;
        for (ContentVersion cv : [ SELECT ContentDocumentId FROM ContentVersion WHERE OwnerId =: this.oppOwner[0].Owner.Id ]) {
            if (cv.ContentDocumentId == oppDoc) { 
            this.oppDocId = cv.Id; 
            } 
        } 
    }
    //public void getOppDocumentId() { 
    //    List<ContentDocumentLink> oppDocs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: this.opportunityId]; 
    //    Id oppDoc = oppDocs[0].ContentDocumentId;
    //    this.oppDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: oppDoc]; 
    //}
    public void buildRecipients() { 
        // Add opportunity owner as recipient #1 
        dfsle.Recipient mySender = dfsle.Recipient.fromSource( 
            this.oppOwner[0].Owner.Name, 
            this.oppOwner[0].Owner.Email, 
            null,
            'Signer 1', 
            new dfsle.Entity(this.oppOwner[0].Owner.Id)
        );
        this.myRecipients.add(mySender);
        // Add client contact as recipient #2 
        for (OpportunityContactRole m : [ SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId = :this.opportunityId ]) { 
            Contact mycontact = [ SELECT Name, Email, Id FROM Contact WHERE Id = :m.ContactId ]; 
                dfsle.Recipient myRecipient = dfsle.Recipient.fromSource( 
                    mycontact.Name, 
                    mycontact.Email, 
                    null,
                    'Signer 2', 
                    new dfsle.Entity(mycontact.Id)
                );
            this.myRecipients.add(myRecipient); 
        } 
    }
    // Uses Apex Toolkit's Envelope Service & DocumentService 
    public void buildEnvelope() { 
        List<dfsle.Document> myDocuments = dfsle.DocumentService.getDocuments( ContentVersion.getSObjectType(), new Set<Id> {this.oppDocId} );
        this.myEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(this.opportunityId)); 
        this.myEnvelope = this.myEnvelope.withRecipients(this.myRecipients); 
        this.myEnvelope = this.myEnvelope.withDocuments(myDocuments); 
    }
}