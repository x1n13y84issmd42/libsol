import { network } from 'hardhat';
import 'node:assert';
import assert from '../../utility/assert.js';
import { describe, it } from 'node:test';
import { soltest } from '../../utility/soltest.js';

describe("Owned", async function () {
	const { viem } = await network.connect();

	const clients = await viem.getWalletClients();
	const owner1 = clients[0];
	const owner2 = clients[1];

	const cOwned = await viem.deployContract("TestableOwned", [], {client: {wallet: owner1}});

	it ("OnlyOwner - revert OnlyOwnerAllowed", async function () {
		await cOwned.read.test({account: owner1.account});

		await assert.reverts(
			cOwned.read.test({account: owner2.account}),
			'OnlyOwnerAllowed',
			owner2.account.address,
		);
	});

	it ("transferOwnership() - revert OnlyOwnerAllowed", async function () {
		await assert.reverts(
			cOwned.write.transferOwnership([owner2.account.address], {account: owner2.account}),
			'OnlyOwnerAllowed',
			owner2.account.address,
		);
	});

	it ("transferOwnership() to address(0) - revert InvalidOwner", async function () {
		await assert.reverts(
			cOwned.write.transferOwnership([soltest.Address0], {account: owner1.account}),
			'InvalidOwner',
			soltest.Address0,
		);
	});

	it ("transferOwnership()", async function () {
		await cOwned.write.transferOwnership([owner2.account.address], {account: owner1.account}),

		// After transfer the former owner cannot access the contract.
		await assert.reverts(
			cOwned.read.test({account: owner1.account}),
			'OnlyOwnerAllowed',
			owner1.account.address,
		);

		// But the new one can.
		await cOwned.read.test({account: owner2.account});
	});
});
