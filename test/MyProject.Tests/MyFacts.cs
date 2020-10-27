// Copyright (©) NewOrbit Ltd. All rights reserved.
namespace MyProject.Tests
{
    using System;
    using System.Linq;
    using Shouldly;
    using Xunit;

    public class MyFacts
    {
        [Fact]
        public void Should_pass_a_test()
        {
            // Arrange
            var start = DateTime.Now;

            // Act
            var end = DateTime.Now.Ticks;

            // Assert
            start.Ticks.ShouldBeLessThanOrEqualTo(end);
            start.ShouldBe(DateTime.Now, new TimeSpan(1_000 * 100), "Test didn't run within 1 second.");
        }
    }
}
