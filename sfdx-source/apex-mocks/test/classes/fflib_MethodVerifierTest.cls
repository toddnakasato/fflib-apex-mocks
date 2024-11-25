@IsTest
public class fflib_MethodVerifierTest {
    public class TestMethodVerifier extends fflib_MethodVerifier {
        private Integer actualCallCount = 0;
        private fflib_QualifiedMethod lastMethodCalled;
        private fflib_MethodArgValues lastMethodArgs;

        protected override void verify(fflib_QualifiedMethod qm, fflib_MethodArgValues methodArg, fflib_VerificationMode verificationMode) {
            this.lastMethodCalled = qm;
            this.lastMethodArgs = methodArg;

            Boolean isVerified = false;

            switch on verificationMode.Method {
                when times {
                    isVerified = actualCallCount == verificationMode.VerifyMin;
                }
                when atLeast {
                    isVerified = actualCallCount >= verificationMode.VerifyMin;
                }
                when atMost {
                    isVerified = actualCallCount <= verificationMode.VerifyMax;
                }
                when between {
                    isVerified = actualCallCount >= verificationMode.VerifyMin && actualCallCount <= verificationMode.VerifyMax;
                }
                when atLeastOnce {
                    isVerified = actualCallCount >= 1;
                }
                when else {
                    isVerified = actualCallCount == verificationMode.VerifyMin;
                }
            }

            if (!isVerified) {
                throwException(
                    qm,
                    '', // inOrder
                    verificationMode.VerifyMin,
                    '', // qualifier
                    actualCallCount,
                    verificationMode.CustomAssertMessage,
                    methodArg,
                    null,
                    new List<fflib_MethodArgValues>{ methodArg }
                );
            }
        }

        protected override void validateMode(fflib_VerificationMode verificationMode) {
            if (verificationMode == null) {
                throw new fflib_ApexMocks.ApexMocksException('Verification mode cannot be null');
            }
        }

        // Test-visible method to access capture
        public void testCapture(List<fflib_IMatcher> matchers) {
            capture(matchers);
        }

        public void setCallCount(Integer count) {
            this.actualCallCount = count;
        }

        public fflib_QualifiedMethod getLastMethodCalled() {
            return this.lastMethodCalled;
        }

        public fflib_MethodArgValues getLastMethodArgs() {
            return this.lastMethodArgs;
        }
    }

    private class TestMatcher implements fflib_IMatcher {
        public Object capturedArg;
        public Boolean matchCalled = false;

        public Boolean matches(Object arg) {
            matchCalled = true;
            capturedArg = arg;
            return true;
        }
    }

    private class TestMatcher2 implements fflib_IMatcher {
        private String matcherDescription;

        public TestMatcher2(String description) {
            this.matcherDescription = description;
        }

        public Boolean matches(Object arg) {
            return true;
        }

        public override String toString() {
            return matcherDescription;
        }
    }

    @IsTest
    private static void testCapture_WithMatchers() {
        TestMethodVerifier verifier = new TestMethodVerifier();
        TestMatcher matcher1 = new TestMatcher();
        TestMatcher matcher2 = new TestMatcher();
        List<fflib_IMatcher> matchers = new List<fflib_IMatcher>{ matcher1, matcher2 };

        Test.startTest();
        verifier.testCapture(matchers);
        Test.stopTest();

        Assert.areNotEqual(null, matchers, 'Matchers list should not be null after capture');
        Assert.areEqual(2, matchers.size(), 'Matchers list should maintain its size');
    }

    @IsTest
    private static void testCapture_WithEmptyMatchersList() {
        TestMethodVerifier verifier = new TestMethodVerifier();
        List<fflib_IMatcher> matchers = new List<fflib_IMatcher>();

        Test.startTest();
        verifier.testCapture(matchers);
        Test.stopTest();

        Assert.areEqual(0, matchers.size(), 'Empty matchers list should remain empty');
    }

    @IsTest
    private static void testVerifyMethodCall_Success() {
        TestMethodVerifier verifier = new TestMethodVerifier();
        verifier.setCallCount(1);

        fflib_QualifiedMethod qm = new fflib_QualifiedMethod('TestClass', 'testMethod', new List<Type>{ String.class });
        fflib_MethodArgValues args = new fflib_MethodArgValues(new List<Object>{ 'test arg' });

        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, args, null);
        fflib_VerificationMode mode = new fflib_VerificationMode().times(1);

        Test.startTest();
        verifier.verifyMethodCall(invocation, mode);
        Test.stopTest();

        Assert.areEqual(qm, verifier.getLastMethodCalled(), 'Method should be recorded correctly');
        Assert.areEqual(args, verifier.getLastMethodArgs(), 'Arguments should be recorded correctly');
    }

    @IsTest
    private static void testVerifyMethodCall_AtLeast() {
        TestMethodVerifier verifier = new TestMethodVerifier();
        verifier.setCallCount(3);

        fflib_QualifiedMethod qm = new fflib_QualifiedMethod('TestClass', 'testMethod', new List<Type>{ String.class });
        fflib_MethodArgValues args = new fflib_MethodArgValues(new List<Object>{ 'test arg' });

        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, args, null);
        fflib_VerificationMode mode = new fflib_VerificationMode().atLeast(2);

        Test.startTest();
        verifier.verifyMethodCall(invocation, mode);
        Test.stopTest();

        Assert.areEqual(qm, verifier.getLastMethodCalled(), 'Method should be recorded correctly');
    }

    @IsTest
    private static void testVerifyMethodCall_FailureWrongCount() {
        TestMethodVerifier verifier = new TestMethodVerifier();
        verifier.setCallCount(0);

        fflib_QualifiedMethod qm = new fflib_QualifiedMethod('TestClass', 'testMethod', new List<Type>{ String.class });
        fflib_MethodArgValues args = new fflib_MethodArgValues(new List<Object>{ 'test arg' });

        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, args, null);
        fflib_VerificationMode mode = new fflib_VerificationMode().times(1).description('Expected the method to be called once');

        try {
            Test.startTest();
            verifier.verifyMethodCall(invocation, mode);
            Test.stopTest();
            Assert.isTrue(false, 'Expected exception was not thrown');
        } catch (fflib_ApexMocks.ApexMocksException e) {
            Assert.isTrue(e.getMessage().contains('EXPECTED COUNT: 1'), 'Exception message should contain expected count');
            Assert.isTrue(e.getMessage().contains('ACTUAL COUNT: 0'), 'Exception message should contain actual count');
            Assert.isTrue(e.getMessage().contains('Expected the method to be called once'), 'Exception message should contain custom message');
        }
    }

    @IsTest
    private static void testVerifyMethodCall_NullVerificationMode() {
        // Arrange
        TestMethodVerifier verifier = new TestMethodVerifier();
        fflib_QualifiedMethod qm = new fflib_QualifiedMethod('TestClass', 'testMethod', new List<Type>{});
        fflib_MethodArgValues args = new fflib_MethodArgValues(new List<Object>{});
        fflib_InvocationOnMock invocation = new fflib_InvocationOnMock(qm, args, null);

        
        try {
            Test.startTest();
            verifier.verifyMethodCall(invocation, null);
            Test.stopTest();
            Assert.isTrue(false, 'Expected exception was not thrown');
        } catch (fflib_ApexMocks.ApexMocksException e) {
            Assert.areEqual('Verification mode cannot be null', e.getMessage(), 'Should throw exception for null verification mode');
        }
    }

    @IsTest
    private static void testDescribe_WithMatchers() {
        List<fflib_IMatcher> matchers = new List<fflib_IMatcher>{ new TestMatcher2('matcher1'), new TestMatcher2('matcher2') };

        Test.startTest();
        String result = fflib_MethodVerifier.describe(matchers);
        Test.stopTest();

        Assert.areEqual('matcher1, matcher2', result, 'Should join matcher descriptions with comma');
    }
}
