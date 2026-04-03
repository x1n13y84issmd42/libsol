import { network } from 'hardhat';
import { describe, it } from 'node:test';
import assert from 'node:assert';

describe("IntervalTree", async function () {
	const { viem } = await network.connect();
	const client = await viem.getPublicClient();

	it ("search()", async function () {
		const lIntervalTree = await viem.deployContract("IntervalTree");
		const cTestableIntervalTree = await viem.deployContract(
			"TestableIntervalTree",
			[],
			{libraries: {
				IntervalTree: lIntervalTree.address
			}}
		);
		const blockN = await client.getBlockNumber();

		await cTestableIntervalTree.write.add([10n, 100n]);
		await cTestableIntervalTree.write.add([50n, 110n]);
		await cTestableIntervalTree.write.add([5n, 15n]);
		await cTestableIntervalTree.write.add([10n, 150n]);
		await cTestableIntervalTree.write.add([155n, 160n]);
		await cTestableIntervalTree.write.add([2n, 3n]);
		await cTestableIntervalTree.write.add([1n, 6n]);

		await cTestableIntervalTree.write.check([51n]);

		const events = (await client.getContractEvents({
			abi: cTestableIntervalTree.abi,
			eventName: 'Result',
			fromBlock: blockN
		})).map(e => e.args);

		assert.deepEqual(events, [
			{a: 10n, b:100n},
			{a: 50n, b:110n},
			{a: 10n, b:150n},
		]);

		const length = await cTestableIntervalTree.read.length();

		assert.equal(length, 7);

	});
});
