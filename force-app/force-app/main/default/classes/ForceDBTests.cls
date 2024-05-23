@IsTest
private class ForceDBTests {

    @IsTest
    static void single_insert_should_fake_insert() {
        
        Account account = new Account(Name = 'Test Account');
        
        ForceDB.SaveResult result = ForceDB.doInsert(account);
        
        Assert.isTrue(result.isSuccess()); 
        Assert.areEqual(account.Id, result.getId());
        Assert.isTrue(result.getErrors().isEmpty());
    }

    @IsTest
    static void pause_and_resume_mocking() {
        
        Account account = new Account();
        
        ForceDB.pauseMocking();

        try {
            ForceDB.doInsert(account);
        } catch (Exception e) {
            Assert.isNotNull(e,'Exception should be thrown because the account is not valid and we are doing a real DML operation');
        }

        ForceDB.resumeMocking();

        Boolean exceptionThrown = false;

        try {
            ForceDB.doInsert(account);
        } catch (Exception e) {
            exceptionThrown = true;
        }

        Assert.isFalse(exceptionThrown,'Exception should not be thrown because we are mocking the DML operation');
        
    }
    
}