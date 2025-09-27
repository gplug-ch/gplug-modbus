#!/usr/bin/env python3
"""
Load testing script for mbpoll Modbus command
Executes: mbpoll -v -t 4 -1 -0 -p 502 -a 201 -r 40070 -c 59 gplugk.local
"""

import argparse
import json
import statistics
import subprocess
import threading
import time
from collections import defaultdict
from datetime import datetime


class MbpollLoadTest:
    def __init__(self, host="gplugk.local", port=502, slave_id=201,
                 register=40070, count=59, verbose=True):
        self.host = host
        self.port = port
        self.slave_id = slave_id
        self.register = register
        self.count = count
        self.verbose = verbose
        self.results = []
        self.lock = threading.Lock()

        # Build the command
        self.cmd = [
            "mbpoll",
            "-t", "4",  # Input registers
            "-1",  # Single poll
            "-0",  # Use Modbus/TCP
            "-p", str(port),
            "-a", str(slave_id),
            "-r", str(register),
            "-c", str(count),
            host
        ]

        if verbose:
            self.cmd.insert(1, "-v")

    def execute_single_test(self, test_id):
        """Execute a single mbpoll command and capture results"""
        start_time = time.time()

        try:
            result = subprocess.run(
                self.cmd,
                capture_output=True,
                text=True,
                timeout=30  # 30 second timeout
            )

            end_time = time.time()
            duration = end_time - start_time

            test_result = {
                'test_id': test_id,
                'timestamp': datetime.now().isoformat(),
                'duration': duration,
                'return_code': result.returncode,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'success': result.returncode == 0
            }

            with self.lock:
                self.results.append(test_result)

            return test_result

        except subprocess.TimeoutExpired:
            end_time = time.time()
            duration = end_time - start_time

            test_result = {
                'test_id': test_id,
                'timestamp': datetime.now().isoformat(),
                'duration': duration,
                'return_code': -1,
                'stdout': '',
                'stderr': 'Command timed out',
                'success': False
            }

            with self.lock:
                self.results.append(test_result)

            return test_result

        except Exception as e:
            end_time = time.time()
            duration = end_time - start_time

            test_result = {
                'test_id': test_id,
                'timestamp': datetime.now().isoformat(),
                'duration': duration,
                'return_code': -1,
                'stdout': '',
                'stderr': str(e),
                'success': False
            }

            with self.lock:
                self.results.append(test_result)

            return test_result

    def run_concurrent_tests(self, num_threads=1, tests_per_thread=1, delay_between_tests=0):
        """Run multiple tests concurrently"""
        print(f"Starting load test with {num_threads} threads, {tests_per_thread} tests per thread")
        print(f"Command: {' '.join(self.cmd)}")
        print("-" * 60)

        threads = []

        def worker(thread_id):
            for i in range(tests_per_thread):
                test_id = f"thread_{thread_id}_test_{i + 1}"
                result = self.execute_single_test(test_id)

                print(f"[{test_id}] {'SUCCESS' if result['success'] else 'FAILED'} "
                      f"in {result['duration']:.3f}s")

                if delay_between_tests > 0 and i < tests_per_thread - 1:
                    time.sleep(delay_between_tests)

        start_time = time.time()

        # Start all threads
        for i in range(num_threads):
            thread = threading.Thread(target=worker, args=(i + 1,))
            threads.append(thread)
            thread.start()

        # Wait for all threads to complete
        for thread in threads:
            thread.join()

        total_time = time.time() - start_time
        print(f"\nAll tests completed in {total_time:.3f}s")

        return self.generate_report()

    def run_sequential_tests(self, num_tests=1, delay_between_tests=0):
        """Run tests sequentially"""
        print(f"Starting sequential load test with {num_tests} tests")
        print(f"Command: {' '.join(self.cmd)}")
        print("-" * 60)

        start_time = time.time()

        for i in range(num_tests):
            test_id = f"sequential_test_{i + 1}"
            result = self.execute_single_test(test_id)

            print(f"[{test_id}] {'SUCCESS' if result['success'] else 'FAILED'} "
                  f"in {result['duration']:.3f}s")

            if delay_between_tests > 0 and i < num_tests - 1:
                time.sleep(delay_between_tests)

        total_time = time.time() - start_time
        print(f"\nAll tests completed in {total_time:.3f}s")

        return self.generate_report()

    def generate_report(self):
        """Generate a comprehensive test report"""
        if not self.results:
            return {"error": "No test results available"}

        successful_tests = [r for r in self.results if r['success']]
        failed_tests = [r for r in self.results if not r['success']]
        durations = [r['duration'] for r in self.results]
        successful_durations = [r['duration'] for r in successful_tests]

        report = {
            'summary': {
                'total_tests': len(self.results),
                'successful_tests': len(successful_tests),
                'failed_tests': len(failed_tests),
                'success_rate': len(successful_tests) / len(self.results) * 100,
                'total_duration': sum(durations),
                'average_duration': statistics.mean(durations),
                'median_duration': statistics.median(durations),
                'min_duration': min(durations),
                'max_duration': max(durations)
            },
            'command': ' '.join(self.cmd),
            'test_parameters': {
                'host': self.host,
                'port': self.port,
                'slave_id': self.slave_id,
                'register': self.register,
                'count': self.count
            }
        }

        if successful_durations:
            report['summary'].update({
                'successful_avg_duration': statistics.mean(successful_durations),
                'successful_median_duration': statistics.median(successful_durations),
                'successful_min_duration': min(successful_durations),
                'successful_max_duration': max(successful_durations)
            })

        # Add standard deviation if we have enough data
        if len(durations) > 1:
            report['summary']['duration_std_dev'] = statistics.stdev(durations)

        # Add error analysis
        if failed_tests:
            error_counts = defaultdict(int)
            for test in failed_tests:
                error_msg = test['stderr'] or f"Return code: {test['return_code']}"
                error_counts[error_msg] += 1

            report['errors'] = dict(error_counts)

        return report

    def save_results(self, filename):
        """Save detailed results to JSON file"""
        data = {
            'test_info': {
                'command': ' '.join(self.cmd),
                'timestamp': datetime.now().isoformat(),
                'host': self.host,
                'port': self.port,
                'slave_id': self.slave_id,
                'register': self.register,
                'count': self.count
            },
            'results': self.results,
            'report': self.generate_report()
        }

        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)

        print(f"Detailed results saved to {filename}")


def main():
    parser = argparse.ArgumentParser(description='Load test mbpoll Modbus command')
    parser.add_argument('--host', default='gplugk.local', help='Target host (default: gplugk.local)')
    parser.add_argument('--port', type=int, default=502, help='Port number (default: 502)')
    parser.add_argument('--slave-id', type=int, default=201, help='Slave ID (default: 201)')
    parser.add_argument('--register', type=int, default=40070, help='Register address (default: 40070)')
    parser.add_argument('--count', type=int, default=59, help='Number of registers (default: 59)')
    parser.add_argument('--threads', type=int, default=1, help='Number of concurrent threads (default: 1)')
    parser.add_argument('--tests-per-thread', type=int, default=1, help='Tests per thread (default: 1)')
    parser.add_argument('--sequential-tests', type=int, help='Run N tests sequentially instead of concurrent')
    parser.add_argument('--delay', type=float, default=0, help='Delay between tests in seconds (default: 0)')
    parser.add_argument('--output', help='Save detailed results to JSON file')
    parser.add_argument('--quiet', action='store_true', help='Disable verbose output from mbpoll')

    args = parser.parse_args()

    # Create load tester
    tester = MbpollLoadTest(
        host=args.host,
        port=args.port,
        slave_id=args.slave_id,
        register=args.register,
        count=args.count,
        verbose=not args.quiet
    )

    # Run tests
    if args.sequential_tests:
        report = tester.run_sequential_tests(args.sequential_tests, args.delay)
    else:
        report = tester.run_concurrent_tests(args.threads, args.tests_per_thread, args.delay)

    # Print report
    print("\n" + "=" * 60)
    print("LOAD TEST REPORT")
    print("=" * 60)
    print(f"Total Tests: {report['summary']['total_tests']}")
    print(f"Successful: {report['summary']['successful_tests']}")
    print(f"Failed: {report['summary']['failed_tests']}")
    print(f"Success Rate: {report['summary']['success_rate']:.1f}%")
    print(f"Average Duration: {report['summary']['average_duration']:.3f}s")
    print(f"Median Duration: {report['summary']['median_duration']:.3f}s")
    print(f"Min Duration: {report['summary']['min_duration']:.3f}s")
    print(f"Max Duration: {report['summary']['max_duration']:.3f}s")

    if 'duration_std_dev' in report['summary']:
        print(f"Std Deviation: {report['summary']['duration_std_dev']:.3f}s")

    if 'errors' in report:
        print("\nErrors:")
        for error, count in report['errors'].items():
            print(f"  {error}: {count} times")

    # Save results if requested
    if args.output:
        tester.save_results(args.output)


if __name__ == "__main__":
    main()