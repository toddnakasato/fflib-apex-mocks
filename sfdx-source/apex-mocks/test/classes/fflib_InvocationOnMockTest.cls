@IsTest
private class fflib_InvocationOnMockTest {
    /*------------------------------------------------------------------------------------------------------------------------
     *
     *  Test Setup Objects
     *
     ------------------------------------------------------------------------------------------------------------------------*/
    private static fflib_QualifiedMethod qm = new fflib_QualifiedMethod('TestClass', 'testMethod', new List<Type>{String.class});
    private static List<Object> args = new List<Object>{'TestArg'};
    private static fflib_MethodArgValues methodArgs = new fflib_MethodArgValues(args);
    private static Account mockAccount = new Account(Name = 'Test Account');

    /*------------------------------------------------------------------------------------------------------------------------
     *
     *  Constructor Tests
     *
     ------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testConstructor() {
        Test.startTest();
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        Test.stopTest();
        
        Assert.areNotEqual(null, invocation, 'Invocation should be created successfully');
    }

    /*------------------------------------------------------------------------------------------------------------------------
     *
     *  Argument Access Tests
     *
     ------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testGetArgument() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        Test.startTest();
        Object result = invocation.getArgument(0);
        Test.stopTest();
        
        Assert.areEqual('TestArg', result, 'Should return correct argument value');
    }

    @isTest
    private static void testGetArguments() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        Test.startTest();
        List<Object> results = invocation.getArguments();
        Test.stopTest();
        
        Assert.areEqual(args, results, 'Should return all arguments');
    }

    @isTest
    private static void testGetMethodArgValues() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        Test.startTest();
        fflib_MethodArgValues result = invocation.getMethodArgValues();
        Test.stopTest();
        
        Assert.areEqual(methodArgs, result, 'Should return method argument values');
    }

    /*------------------------------------------------------------------------------------------------------------------------
     *
     *  Invocation Details Tests
     *
     ------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testGetMethod() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        Test.startTest();
        fflib_QualifiedMethod result = invocation.getMethod();
        Test.stopTest();
        
        Assert.areEqual(qm, result, 'Should return qualified method');
    }

    @isTest
    private static void testGetMock() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        Test.startTest();
        Object result = invocation.getMock();
        Test.stopTest();
        
        Assert.areEqual(mockAccount, result, 'Should return mock instance');
    }

    /*------------------------------------------------------------------------------------------------------------------------
     *
     *  Error Handling Tests
     *
     ------------------------------------------------------------------------------------------------------------------------*/
    @isTest
    private static void testValidateIndexNegative() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        try {
            Test.startTest();
            invocation.getArgument(-1);
            Test.stopTest();
            Assert.isTrue(false, 'Should throw exception for negative index');
        } catch(fflib_ApexMocks.ApexMocksException e) {
            Assert.isTrue(e.getMessage().contains('Invalid index'), 'Should throw correct exception message');
        }
    }

    @isTest
    private static void testValidateIndexTooLarge() {
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, methodArgs, mockAccount);
        
        try {
            Test.startTest();
            invocation.getArgument(args.size());
            Test.stopTest();
            Assert.isTrue(false, 'Should throw exception for index too large');
        } catch(fflib_ApexMocks.ApexMocksException e) {
            Assert.isTrue(e.getMessage().contains('Invalid index'), 'Should throw correct exception message');
        }
    }
}