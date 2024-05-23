public without sharing class ForceDB {

    private static Boolean isMocking = true;

    @TestVisible
    private static void pauseMocking(){
        isMocking = false;
    }

    @TestVisible
    private static void resumeMocking(){
        isMocking = true;
    }
    
    public static ForceDB.SaveResult doInsert(SObject record) {

        ForceDB.SaveResult forceDbResult;

        if(Test.isRunningTest() && isMocking){
            forceDbResult = doMockInsert(record);
        }
        else{
            Database.SaveResult result = Database.insert(record);
            forceDbResult = new ForceDB.RealSaveResult(result);
        }
        
        return forceDbResult;
        
    }

    private static ForceDB.SaveResult doMockInsert(SObject record) {
        
        ForceDB.SaveResult forceDbResult = new ForceDB.FakeSaveResult(record);    
        return forceDbResult;
    }

    public interface SaveResult {
        Boolean isSuccess();
        Id getId();
        List<Database.Error> getErrors();
    }

    private class RealSaveResult implements SaveResult {

        private Database.SaveResult realResult;

        public RealSaveResult(Database.SaveResult realResult){
            this.realResult = realResult;
        }

        public Boolean isSuccess(){
            return this.realResult.isSuccess();
        }

        public Id getId(){
            return this.realResult.getId();
        }

        public List<Database.Error> getErrors(){
            return this.realResult.getErrors();
        }
    }

    private class FakeSaveResult implements SaveResult {

        private Boolean fakeIsSuccess;
        private Id fakeId;

        public FakeSaveResult(SObject record){   
            this.fakeIsSuccess = true;
            this.fakeId = new FakeId().generate(record);
            record.Id = this.fakeId; 
        }

        public Boolean isSuccess(){
            return this.fakeIsSuccess;
        }

        public Id getId(){
            return this.fakeId;
        }

        public List<Database.Error> getErrors(){
            return new List<Database.Error>();
        }
    }

    private class FakeId{

        private Integer startingNumber = 1;

        public String generate(Schema.SObjectType sObjectType) {
            String result = String.valueOf(startingNumber++);
            return sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(12-result.length()) + result;
        }

        public String generate(SObject objectInstance) {
            if(objectInstance.Id == null) {
                return generate(objectInstance.getSObjectType());
            }
            else {  
                return objectInstance.Id;
            }
        }


    }

}