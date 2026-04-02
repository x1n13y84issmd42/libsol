import { network } from 'hardhat';
import { describe, it, afterEach } from 'node:test';
import assert from '../../utility/assert.js';
import * as testutils from '../../utility/testutils.js'
import { getAddress } from 'viem';
import { soltest } from '../../utility/soltest.js';

describe("ERC20Token", async function () {
	const { viem, networkHelpers } = await network.connect();
	const client = await viem.getPublicClient();
	
	const clients = await viem.getWalletClients();
	const contractOwner = clients[0];
	const coinOwner1 = clients[1];
	const coinOwner2 = clients[2];
	const coinSpender = clients[3];
	const coinReceiver = clients[4];

	const cERC20Token = await viem.deployContract("ERC20Token", ["TestCoin", "XTC", 8], {client: {wallet: contractOwner}});

	const addr0 = "0x0000000000000000000000000000000000000000";

	afterEach(async function () {
		// So every case starts with a new block.
		// This is needed to count events.
		networkHelpers.mine();
	});

	it("metadata", async function () {
		const name = await cERC20Token.read.name();
		const symbol = await cERC20Token.read.symbol();
		const decimals = await cERC20Token.read.decimals();

		assert.equal(name, "TestCoin");
		assert.equal(symbol, "XTC");
		assert.equal(decimals, 8);
	});

	it("mint()", async function () {
		const amount1 = 123n;
		const amount2 = 45n;
		await cERC20Token.write.mint([coinOwner1.account.address, amount1], {account: contractOwner.account});
		await cERC20Token.write.mint([coinOwner2.account.address, amount2], {account: contractOwner.account});

		const coinOwner1Balance = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const coinOwner2Balance = await cERC20Token.read.balanceOf([coinOwner2.account.address]);
		const totalSupply = await cERC20Token.read.totalSupply();

		assert.equal(coinOwner1Balance, amount1);
		assert.equal(coinOwner2Balance, amount2);
		assert.equal(totalSupply, amount1 + amount2);
	});

	it("mint() - revert OnlyOwnerAllowed", async function () {
		await assert.reverts(
			cERC20Token.write.mint([coinOwner1.account.address, 121n], {account: coinOwner1.account}),
			'OnlyOwnerAllowed',
			coinOwner1.account.address
		);
	});

	it("mint() to address(0) - revert InvalidReceiver", async function () {
		await assert.reverts(
			cERC20Token.write.mint([soltest.Address0, 1n], {account: contractOwner.account}),
			'InvalidReceiver',
			soltest.Address0
		);
	});

	it("approve()", async function () {
		const blockN = await client.getBlockNumber();

		const allowance1 = await cERC20Token.read.allowance([coinOwner1.account.address, coinSpender.account.address]);
		assert.equal(allowance1, 0);
		
		const approvedAmount = 12n;
		await cERC20Token.write.approve([coinSpender.account.address, approvedAmount], {account: coinOwner1.account});

		const allowance2 = await cERC20Token.read.allowance([coinOwner1.account.address, coinSpender.account.address]);
		assert.equal(allowance2, approvedAmount);

		const events = await client.getContractEvents({
			abi: cERC20Token.abi,
			eventName: 'Approval',
			fromBlock: blockN
		});

		assert.equal(events.length, 1);
		assert.deepEqual(events[0].args, {
			owner: getAddress(coinOwner1.account.address),
			spender: getAddress(coinSpender.account.address),
			amount: approvedAmount,
		});
	});

	it("approve() for address(0) - revert InvalidReceiver", async function () {
		await assert.reverts(
			cERC20Token.write.approve([soltest.Address0, 1n], {account: contractOwner.account}),
			'InvalidReceiver',
			soltest.Address0,
		);
	});

	it("transfer()", async function () {
		const amount = 5n;
		const blockN = await client.getBlockNumber();

		const balanceOwner1 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver1 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);
		
		await cERC20Token.write.transfer([coinReceiver.account.address, amount], {account: coinOwner1.account});

		const balanceOwner2 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver2 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);

		assert.equal(balanceOwner2, balanceOwner1 - amount);
		assert.equal(balanceReceiver2, balanceReceiver1 + amount);

		const events = await client.getContractEvents({
			abi: cERC20Token.abi,
			eventName: 'Transfer',
			fromBlock: blockN,
		});

		assert.equal(events.length, 1);
		assert.deepEqual(events[0].args, {
			from: getAddress(coinOwner1.account.address),
			to: getAddress(coinReceiver.account.address),
			amount,
		});
	});

	it("transfer() over 9000 - revert InsufficientFunds", async function () {
		const amount = 9001n;
		const blockN = await client.getBlockNumber();

		const balanceOwner1 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver1 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);

		await assert.reverts(
			cERC20Token.write.transfer([coinReceiver.account.address, amount], {account: coinOwner1.account}),
			'InsufficientFunds',
			coinOwner1.account.address,
			balanceOwner1,
			amount,
		);

		const balanceOwner2 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver2 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);

		// Balances should stay unchanged.
		assert.equal(balanceOwner2, balanceOwner1);
		assert.equal(balanceReceiver2, balanceReceiver1);

		const events = await client.getContractEvents({
			abi: cERC20Token.abi,
			eventName: 'Transfer',
			fromBlock: blockN,
		});

		// No events should have fired.
		assert.equal(events.length, 0);
	});

	it("transfer() to address(0) - revert InvalidReceiver", async function () {
		await assert.reverts(
			cERC20Token.write.transfer([soltest.Address0, 1n], {account: coinOwner1.account}),
			'InvalidReceiver',
			soltest.Address0,
		);
	});

	it("transferFrom() coin owner", async function () {
		const amount = 2n;
		const blockN = await client.getBlockNumber();

		const balanceOwner1 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver1 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);
		
		await cERC20Token.write.transferFrom([coinOwner1.account.address, coinReceiver.account.address, amount], {account: coinOwner1.account});

		const balanceOwner2 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver2 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);

		assert.equal(balanceOwner2, balanceOwner1 - amount);
		assert.equal(balanceReceiver2, balanceReceiver1 + amount);

		const events = await client.getContractEvents({
			abi: cERC20Token.abi,
			eventName: 'Transfer',
			fromBlock: blockN,
		});

		assert.equal(events.length, 1);
		assert.deepEqual(events[0].args, {
			from: getAddress(coinOwner1.account.address),
			to: getAddress(coinReceiver.account.address),
			amount,
		});
	});

	it("transferFrom() approved spender", async function () {
		const amount = 2n;
		const blockN = await client.getBlockNumber();

		const balanceOwner1 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver1 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);
		const allowanceSpender1 = await cERC20Token.read.allowance([coinOwner1.account.address, coinSpender.account.address]);
		
		await cERC20Token.write.transferFrom(
			[coinOwner1.account.address, coinReceiver.account.address, amount],
			{account: coinSpender.account},
		);

		const balanceOwner2 = await cERC20Token.read.balanceOf([coinOwner1.account.address]);
		const balanceReceiver2 = await cERC20Token.read.balanceOf([coinReceiver.account.address]);
		const allowanceSpender2 = await cERC20Token.read.allowance([coinOwner1.account.address, coinSpender.account.address]);

		assert.equal(balanceOwner2, balanceOwner1 - amount);
		assert.equal(balanceReceiver2, balanceReceiver1 + amount);
		assert.equal(allowanceSpender2, allowanceSpender1 - amount);

		const events = await client.getContractEvents({
			abi: cERC20Token.abi,
			eventName: 'Transfer',
			fromBlock: blockN,
		});

		assert.equal(events.length, 1);
		assert.deepEqual(events[0].args, {
			from: getAddress(coinOwner1.account.address),
			to: getAddress(coinReceiver.account.address),
			amount,
		});
	});

	it("transferFrom() over 9000 - revert InsufficientAllowance", async function () {
		const amount = 9001n;

		const spenderAllowance = await cERC20Token.read.allowance([coinOwner1.account.address, coinSpender.account.address]);

		const promise = cERC20Token.write.transferFrom(
			[coinOwner1.account.address, coinReceiver.account.address, amount],
			{account: coinSpender.account},
		);

		await assert.reverts(promise, 'InsufficientAllowance',
			coinOwner1.account.address,
			coinSpender.account.address,
			spenderAllowance,
			amount,
		);
	});

	it("transferFrom() from address(0) - revert InvalidSender", async function () {
		const amount = 2n;

		const promise = cERC20Token.write.transferFrom(
			[soltest.Address0, coinReceiver.account.address, amount],
			{account: coinSpender.account},
		);

		await assert.reverts(promise, 'InvalidSender', soltest.Address0);
	});
});
