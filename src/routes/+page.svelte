<script>
	import { Tabs } from 'bits-ui';
	import { Card } from 'bits-ui';
	import { Select } from 'bits-ui';
	import { Button } from 'bits-ui';
	import { Input } from 'bits-ui';
	import { Label } from 'bits-ui';
	import { Textarea } from 'bits-ui';
	import { Checkbox } from 'bits-ui';
	import { Slider } from 'bits-ui';
	import { Badge } from 'bits-ui';
	import { Separator } from 'bits-ui';

	let mode = $state('wifi'); // 'wifi' or 'text'
	let wifiSSID = $state('');
	let wifiPassword = $state('');
	let wifiSecurity = $state('WPA');
	let wifiHidden = $state(false);
	let customText = $state('');

	let qrCodeDataURL = $state('');
	let size = $state([256]);
	let errorCorrectionLevel = $state('M');
	let isGenerating = $state(false);

	const securityOptions = [
		{ value: 'WPA', label: 'WPA/WPA2/WPA3 (Recommended)' },
		{ value: 'SAE', label: 'WPA3-Personal' },
		{ value: 'WPA2', label: 'WPA2-Personal' },
		{ value: 'WEP', label: 'WEP (Legacy)' },
		{ value: 'nopass', label: 'Open (No Password)' }
	];

	const errorLevels = [
		{ value: 'L', label: 'Low (7%)' },
		{ value: 'M', label: 'Medium (15%)' },
		{ value: 'Q', label: 'Quartile (25%)' },
		{ value: 'H', label: 'High (30%)' }
	];

	// Generate WiFi QR code string
	function generateWiFiString() {
		const security = wifiSecurity;
		const ssid = wifiSSID.replace(/[\\;,:]/g, '\\$&');
		const password = wifiPassword.replace(/[\\;,:]/g, '\\$&');
		const hidden = wifiHidden ? 'true' : 'false';

		return `WIFI:T:${security};S:${ssid};P:${password};H:${hidden};;`;
	}

	// Get the text to encode based on mode
	function getTextToEncode() {
		if (mode === 'wifi') {
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
				width: size[0],
				margin: 2,
				color: {
					dark: '#1f2937',
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
		const filename = mode === 'wifi' ? `wifi-${wifiSSID || 'network'}.png` : 'qrcode.png';
		link.download = filename;
		link.href = qrCodeDataURL;
		link.click();
	}

	// Auto-generate QR code when inputs change
	$effect(() => {
		generateQRCode();
	});
</script>

<div
	class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-4 sm:p-6 lg:p-8 dark:from-gray-950 dark:to-gray-900"
>
	<div class="mx-auto max-w-4xl">
		<!-- Header -->
		<div class="mb-8 text-center">
			<h1
				class="mb-2 bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-4xl font-bold text-transparent"
			>
				QR Code Generator
			</h1>
			<p class="text-gray-600 dark:text-gray-400">
				Generate WiFi connection codes and custom QR codes instantly
			</p>
		</div>

		<div class="grid gap-8 lg:grid-cols-2">
			<!-- Input Section -->
			<Card
				class="border-gray-200 bg-white/80 p-6 shadow-xl backdrop-blur-sm dark:border-gray-800 dark:bg-gray-900/80"
			>
				<Tabs.Root bind:value={mode} class="w-full">
					<Tabs.List
						class="mb-6 grid w-full grid-cols-2 rounded-lg bg-gray-100 p-1 dark:bg-gray-800"
					>
						<Tabs.Trigger
							value="wifi"
							class="flex items-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-all data-[state=active]:bg-white data-[state=active]:text-gray-900 data-[state=active]:shadow-sm dark:data-[state=active]:bg-gray-700 dark:data-[state=active]:text-white"
						>
							<span class="text-lg">📶</span>
							WiFi Network
						</Tabs.Trigger>
						<Tabs.Trigger
							value="text"
							class="flex items-center gap-2 rounded-md px-4 py-2 text-sm font-medium transition-all data-[state=active]:bg-white data-[state=active]:text-gray-900 data-[state=active]:shadow-sm dark:data-[state=active]:bg-gray-700 dark:data-[state=active]:text-white"
						>
							<span class="text-lg">📝</span>
							Custom Text
						</Tabs.Trigger>
					</Tabs.List>

					<Tabs.Content value="wifi" class="space-y-6">
						<div class="mb-4 flex items-center gap-2">
							<span class="text-2xl">🔐</span>
							<h3 class="text-xl font-semibold text-gray-900 dark:text-white">
								WiFi Network Details
							</h3>
						</div>

						<div class="space-y-4">
							<div class="space-y-2">
								<Label class="text-sm font-medium text-gray-700 dark:text-gray-300">
									Network Name (SSID) <span class="text-red-500">*</span>
								</Label>
								<Input
									bind:value={wifiSSID}
									placeholder="Enter your WiFi network name"
									class="border-gray-300 bg-white focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-800"
								/>
							</div>

							<div class="space-y-2">
								<Label class="text-sm font-medium text-gray-700 dark:text-gray-300">Password</Label>
								<Input
									type="password"
									bind:value={wifiPassword}
									placeholder="Enter WiFi password (leave empty for open networks)"
									class="border-gray-300 bg-white focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-800"
								/>
							</div>

							<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
								<div class="space-y-2">
									<Label class="text-sm font-medium text-gray-700 dark:text-gray-300"
										>Security Type</Label
									>
									<Select.Root bind:selected={wifiSecurity}>
										<Select.Trigger
											class="w-full border-gray-300 bg-white focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-800"
										>
											<Select.Value placeholder="Select security type" />
										</Select.Trigger>
										<Select.Content
											class="border-gray-300 bg-white dark:border-gray-600 dark:bg-gray-800"
										>
											{#each securityOptions as option}
												<Select.Item
													value={option.value}
													class="hover:bg-gray-100 dark:hover:bg-gray-700"
												>
													{option.label}
												</Select.Item>
											{/each}
										</Select.Content>
									</Select.Root>
								</div>

								<div class="flex items-center space-x-3 pt-6">
									<Checkbox
										bind:checked={wifiHidden}
										class="data-[state=checked]:border-blue-600 data-[state=checked]:bg-blue-600"
									/>
									<Label
										class="cursor-pointer text-sm font-medium text-gray-700 dark:text-gray-300"
									>
										Hidden Network
									</Label>
								</div>
							</div>

							{#if wifiSSID}
								<Card
									class="border-gray-200 bg-gray-50 p-4 dark:border-gray-700 dark:bg-gray-800/50"
								>
									<div class="mb-2 flex items-center gap-2">
										<span class="text-sm">📋</span>
										<h4 class="text-sm font-medium text-gray-700 dark:text-gray-300">
											Connection String Preview
										</h4>
									</div>
									<code
										class="block rounded border bg-white p-2 font-mono text-xs break-all text-gray-800 dark:bg-gray-900 dark:text-gray-200"
									>
										{generateWiFiString()}
									</code>
								</Card>
							{/if}
						</div>
					</Tabs.Content>

					<Tabs.Content value="text" class="space-y-6">
						<div class="mb-4 flex items-center gap-2">
							<span class="text-2xl">📝</span>
							<h3 class="text-xl font-semibold text-gray-900 dark:text-white">Custom Text</h3>
						</div>

						<div class="space-y-2">
							<Label class="text-sm font-medium text-gray-700 dark:text-gray-300"
								>Enter text or URL</Label
							>
							<Textarea
								bind:value={customText}
								placeholder="Enter text, URL, or any data you want to encode..."
								rows={4}
								class="resize-none border-gray-300 bg-white focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-800"
							/>
						</div>
					</Tabs.Content>
				</Tabs.Root>

				<Separator class="my-6 bg-gray-200 dark:bg-gray-700" />

				<!-- Options Section -->
				<div class="space-y-6">
					<h3 class="text-lg font-semibold text-gray-900 dark:text-white">Generation Options</h3>

					<div class="grid grid-cols-1 gap-6 md:grid-cols-2">
						<div class="space-y-3">
							<div class="flex items-center justify-between">
								<Label class="text-sm font-medium text-gray-700 dark:text-gray-300">Size</Label>
								<Badge
									variant="secondary"
									class="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
								>
									{size[0]}px
								</Badge>
							</div>
							<Slider bind:value={size} min={128} max={512} step={32} class="w-full" />
							<div class="flex justify-between text-xs text-gray-500 dark:text-gray-400">
								<span>128px</span>
								<span>512px</span>
							</div>
						</div>

						<div class="space-y-2">
							<Label class="text-sm font-medium text-gray-700 dark:text-gray-300"
								>Error Correction</Label
							>
							<Select.Root bind:selected={errorCorrectionLevel}>
								<Select.Trigger
									class="w-full border-gray-300 bg-white focus:border-blue-500 focus:ring-blue-500 dark:border-gray-600 dark:bg-gray-800"
								>
									<Select.Value placeholder="Select error correction level" />
								</Select.Trigger>
								<Select.Content
									class="border-gray-300 bg-white dark:border-gray-600 dark:bg-gray-800"
								>
									{#each errorLevels as level}
										<Select.Item
											value={level.value}
											class="hover:bg-gray-100 dark:hover:bg-gray-700"
										>
											{level.label}
										</Select.Item>
									{/each}
								</Select.Content>
							</Select.Root>
						</div>
					</div>
				</div>
			</Card>

			<!-- Output Section -->
			<Card
				class="border-gray-200 bg-white/80 p-6 shadow-xl backdrop-blur-sm dark:border-gray-800 dark:bg-gray-900/80"
			>
				<div class="flex h-full min-h-[400px] flex-col items-center justify-center">
					{#if isGenerating}
						<div class="flex flex-col items-center gap-4">
							<div class="relative">
								<div
									class="h-12 w-12 animate-spin rounded-full border-4 border-gray-200 border-t-blue-600"
								></div>
								<div
									class="absolute inset-0 h-12 w-12 animate-spin rounded-full border-4 border-transparent border-r-purple-600"
									style="animation-delay: -0.5s;"
								></div>
							</div>
							<p class="font-medium text-gray-600 dark:text-gray-400">Generating QR code...</p>
						</div>
					{:else if qrCodeDataURL}
						<div class="flex w-full flex-col items-center gap-6">
							<div class="group relative">
								<img
									src={qrCodeDataURL}
									alt="Generated QR Code"
									class="group-hover:shadow-3xl rounded-2xl border-2 border-gray-200 bg-white shadow-2xl transition-all duration-300 dark:border-gray-700"
								/>
								<div
									class="absolute inset-0 rounded-2xl bg-gradient-to-tr from-blue-500/10 to-purple-500/10 opacity-0 transition-opacity duration-300 group-hover:opacity-100"
								></div>
							</div>

							<div class="flex w-full flex-col items-center gap-4">
								<Button
									onclick={downloadQRCode}
									class="rounded-lg bg-gradient-to-r from-blue-600 to-purple-600 px-8 py-3 font-medium text-white shadow-lg transition-all duration-300 hover:from-blue-700 hover:to-purple-700 hover:shadow-xl"
								>
									<span class="mr-2">💾</span>
									Download QR Code
								</Button>

								{#if mode === 'wifi'}
									<Card
										class="w-full max-w-md border-blue-200 bg-gradient-to-r from-blue-50 to-purple-50 p-4 dark:border-blue-800 dark:from-blue-950/20 dark:to-purple-950/20"
									>
										<div class="mb-3 flex items-center gap-2">
											<span class="text-lg">📱</span>
											<h4 class="font-semibold text-blue-900 dark:text-blue-100">How to use</h4>
										</div>
										<div class="space-y-2 text-sm text-blue-800 dark:text-blue-200">
											<div class="flex items-start gap-2">
												<span class="min-w-fit font-medium">iPhone:</span>
												<span>Open Camera app and point at QR code</span>
											</div>
											<div class="flex items-start gap-2">
												<span class="min-w-fit font-medium">Android:</span>
												<span>Use Camera app or WiFi settings QR scanner</span>
											</div>
											<div class="flex items-start gap-2">
												<span class="min-w-fit font-medium">Note:</span>
												<span>For WPA3 networks, ensure your device supports WPA3</span>
											</div>
											<div class="flex items-start gap-2">
												<span class="min-w-fit font-medium">Guests:</span>
												<span>Scan to automatically connect to your WiFi!</span>
											</div>
										</div>
									</Card>
								{/if}
							</div>
						</div>
					{:else}
						<div class="space-y-4 text-center">
							<div class="mb-4 text-6xl">
								{mode === 'wifi' ? '📶' : '📝'}
							</div>
							<p class="text-lg font-medium text-gray-500 dark:text-gray-400">
								{mode === 'wifi'
									? 'Enter your WiFi network details to generate a connection QR code'
									: 'Enter some text to generate a QR code'}
							</p>
						</div>
					{/if}
				</div>
			</Card>
		</div>
	</div>
</div>
