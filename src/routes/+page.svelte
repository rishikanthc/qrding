<script>
	import { Select } from 'bits-ui';
	import { Button } from 'bits-ui';
	import { Slider } from 'bits-ui';

	let mode = $state({ value: 'wifi', label: 'WiFi Network' });
	let wifiSSID = $state('');
	let wifiPassword = $state('');
	let wifiSecurity = $state({ value: 'WPA', label: 'WPA/WPA2' });
	let wifiHidden = $state(false);
	let customText = $state('');

	let qrCodeDataURL = $state('');
	let size = $state(256);
	let errorCorrectionLevel = $state('M');
	let isGenerating = $state(false);

	const modeOptions = [
		{ value: 'wifi', label: 'WiFi Network' },
		{ value: 'text', label: 'Custom Text' }
	];

	const securityOptions = [
		{ value: 'WPA', label: 'WPA/WPA2' },
		{ value: 'WEP', label: 'WEP' },
		{ value: 'nopass', label: 'Open' }
	];

	// Generate WiFi QR code string
	function generateWiFiString() {
		const security = wifiSecurity.value;
		const ssid = wifiSSID.replace(/[\\;,:]/g, '\\$&');
		const password = wifiPassword.replace(/[\\;,:]/g, '\\$&');
		const hidden = wifiHidden ? 'true' : 'false';

		return `WIFI:T:${security};S:${ssid};P:${password};H:${hidden};;`;
	}

	// Get the text to encode based on mode
	function getTextToEncode() {
		if (mode.value === 'wifi') {
			if (!wifiSSID.trim()) return '';
			return generateWiFiString();
		}
		return customText;
	}

	// QR code generation function
	async function generateQRCode() {
		const textToEncode = getTextToEncode();

		if (!textToEncode.trim()) {
			qrCodeDataURL = '';
			return;
		}

		isGenerating = true;

		try {
			const QRCode = await import('https://cdn.skypack.dev/qrcode');

			const options = {
				width: size,
				margin: 2,
				color: {
					dark: '#000000',
					light: '#ffffff'
				},
				errorCorrectionLevel: errorCorrectionLevel
			};

			qrCodeDataURL = await QRCode.toDataURL(textToEncode, options);
		} catch (error) {
			console.error('Error generating QR code:', error);
			qrCodeDataURL = '';
		} finally {
			isGenerating = false;
		}
	}

	// Download QR code as image
	function downloadQRCode() {
		if (!qrCodeDataURL) return;

		const link = document.createElement('a');
		const filename = mode.value === 'wifi' ? `wifi-${wifiSSID || 'network'}.png` : 'qrcode.png';
		link.download = filename;
		link.href = qrCodeDataURL;
		link.click();
	}

	// Auto-generate QR code when inputs change
	$effect(() => {
		generateQRCode();
	});
</script>

<div class="flex min-h-screen items-center justify-center bg-white p-8">
	<div class="w-full max-w-[900px] bg-white p-8">
		<div class="grid grid-cols-2 gap-8">
			<!-- Left Section -->
			<div class="space-y-6">
				<!-- Mode Selector -->
				<div>
					<Select.Root type="single" bind:value={mode}>
						<Select.Trigger
							class="flex h-10 w-full items-center justify-between rounded-lg border border-black bg-white px-4 text-sm font-medium transition-colors hover:bg-gray-50"
						>
							<span>{mode.label}</span>
							<svg width="16" height="16" viewBox="0 0 16 16" fill="none">
								<path
									d="M4 6L8 10L12 6"
									stroke="currentColor"
									stroke-width="2"
									stroke-linecap="round"
									stroke-linejoin="round"
								/>
							</svg>
						</Select.Trigger>
						<Select.Portal>
							<Select.Content
								class="z-50 overflow-hidden rounded-lg border border-black bg-white shadow-lg"
								sideOffset={10}
							>
								<Select.Viewport class="p-1">
									{#each modeOptions as option}
										<Select.Item
											value={option}
											class="cursor-pointer rounded px-4 py-2 text-sm hover:bg-gray-100 data-[highlighted]:bg-gray-100"
										>
											{#snippet children({ selected })}
												{option.label}
											{/snippet}
										</Select.Item>
									{/each}
								</Select.Viewport>
							</Select.Content>
						</Select.Portal>
					</Select.Root>
				</div>

				<!-- Input Fields -->
				{#if mode.value === 'wifi'}
					<div class="space-y-4">
						<div>
							<label class="mb-2 block text-sm font-medium">Network Name</label>
							<input
								type="text"
								bind:value={wifiSSID}
								placeholder="Enter SSID"
								class="h-10 w-full rounded-lg border border-black px-4 text-sm focus:ring-2 focus:ring-black focus:outline-none"
							/>
						</div>

						<div>
							<label class="mb-2 block text-sm font-medium">Password</label>
							<input
								type="password"
								bind:value={wifiPassword}
								placeholder="Enter password"
								class="h-10 w-full rounded-lg border border-black px-4 text-sm focus:ring-2 focus:ring-black focus:outline-none"
							/>
						</div>

						<div>
							<label class="mb-2 block text-sm font-medium">Security</label>
							<Select.Root type="single" bind:value={wifiSecurity}>
								<Select.Trigger
									class="flex h-12 w-full items-center justify-between rounded-lg border border-black bg-white px-4 text-sm transition-colors hover:bg-gray-50"
								>
									<span>{wifiSecurity.label}</span>
									<svg width="16" height="16" viewBox="0 0 16 16" fill="none">
										<path
											d="M4 6L8 10L12 6"
											stroke="currentColor"
											stroke-width="2"
											stroke-linecap="round"
											stroke-linejoin="round"
										/>
									</svg>
								</Select.Trigger>
								<Select.Portal>
									<Select.Content
										class="z-50 overflow-hidden rounded-lg border border-black bg-white shadow-lg"
										sideOffset={8}
									>
										<Select.Viewport class="p-1">
											{#each securityOptions as option}
												<Select.Item
													value={option}
													class="cursor-pointer rounded px-4 py-2 text-sm hover:bg-gray-100 data-[highlighted]:bg-gray-100"
												>
													{#snippet children({ selected })}
														{option.label}
													{/snippet}
												</Select.Item>
											{/each}
										</Select.Viewport>
									</Select.Content>
								</Select.Portal>
							</Select.Root>
						</div>

						<div class="flex items-center space-x-3">
							<input
								type="checkbox"
								id="hidden"
								bind:checked={wifiHidden}
								class="h-4 w-4 rounded border-black text-black focus:ring-black"
							/>
							<label for="hidden" class="text-sm font-medium">Hidden Network</label>
						</div>
					</div>
				{:else}
					<div>
						<label class="mb-2 block text-sm font-medium">Custom Text</label>
						<textarea
							bind:value={customText}
							placeholder="Enter text or URL"
							rows={8}
							class="w-full resize-none rounded-lg border border-black px-4 py-3 text-sm focus:ring-2 focus:ring-black focus:outline-none"
						></textarea>
					</div>
				{/if}

				<!-- Size Slider -->
				<div class="space-y-3">
					<div class="flex items-center justify-between">
						<label class="text-sm font-medium">Size</label>
						<span class="text-sm font-medium">{size}px</span>
					</div>
					<Slider.Root
						bind:value={size}
						min={128}
						max={512}
						step={32}
						type="single"
						class="relative flex h-5 w-full touch-none items-center select-none"
					>
						<span
							class="relative h-2 w-full grow cursor-pointer overflow-hidden rounded-full bg-gray-200"
						>
							<Slider.Range class="absolute h-full bg-black" />
						</span>
						<Slider.Thumb
							index={0}
							class="block h-4 w-4 cursor-pointer rounded-full border-2 border-black bg-white shadow-sm transition-shadow hover:shadow-md focus:ring-2 focus:ring-black focus:ring-offset-2 focus:outline-none"
						/>
					</Slider.Root>
				</div>
			</div>

			<!-- Right Section -->
			<div class="flex flex-col items-center justify-center space-y-6">
				{#if isGenerating}
					<div class="flex h-64 w-64 items-center justify-center">
						<div
							class="h-8 w-8 animate-spin rounded-full border-2 border-gray-300 border-t-black"
						></div>
					</div>
				{:else if qrCodeDataURL}
					<div class="rounded-lg border border-black p-4">
						<img
							src={qrCodeDataURL}
							alt="QR Code"
							class="block"
							style="width: {size}px; height: {size}px; max-width: 100%;"
						/>
					</div>
				{:else}
					<div
						class="flex h-64 w-64 items-center justify-center rounded-lg border border-dashed border-gray-300"
					>
						<p class="text-sm text-gray-500">QR code will appear here</p>
					</div>
				{/if}

				{#if qrCodeDataURL}
					<Button.Root
						onclick={downloadQRCode}
						class="h-8 cursor-pointer rounded-lg border border-black bg-black px-6 text-sm font-medium text-white transition-colors hover:bg-gray-900"
					>
						Download Image
					</Button.Root>
				{/if}
			</div>
		</div>
	</div>
</div>

<style>
	/* Empty style block to ensure proper CSS processing */
</style>
