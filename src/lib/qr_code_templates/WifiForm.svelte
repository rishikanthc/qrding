<script>
	import { Select } from 'bits-ui';

	let ssid = $state('');
	let password = $state('');
	let securityValue = $state('WPA'); // Default to WPA
	let isHidden = $state(false);

	let { generatedString = $bindable(), filenameHint = $bindable() } = $props();

	const securityOptions = [
		{ value: 'WPA', label: 'WPA/WPA2' },
		{ value: 'WEP', label: 'WEP' },
		{ value: 'nopass', label: 'Open (No Password)' }
	];

	const currentWifiSecurityLabel = $derived(
		securityOptions.find((opt) => opt.value === securityValue)?.label
	);

	function generateWiFiString(p_ssid, p_password, p_securityValue, p_hiddenBool) {
		if (!p_ssid.trim()) return ''; // Don't generate if SSID is empty

		const securityType = p_securityValue; // 'WPA', 'WEP', or 'nopass'
		// Escape special characters for WiFi string components.
		// The characters to escape are backslash, semicolon, comma, double quote, and colon.
		const escSsid = p_ssid.replace(/([\\;,":])/g, '\\$1');
		const escPassword = p_password.replace(/([\\;,":])/g, '\\$1');
		const hiddenParam = p_hiddenBool ? 'true' : 'false';

		let wifiString = `WIFI:T:${securityType};S:${escSsid};`;
		if (securityType !== 'nopass') {
			wifiString += `P:${escPassword};`;
		}
		wifiString += `H:${hiddenParam};;`;
		return wifiString;
	}

	$effect(() => {
		generatedString = generateWiFiString(ssid, password, securityValue, isHidden);
		filenameHint = `wifi-${(ssid || 'network').replace(/[^\\w-]/g, '_')}`;
	});
</script>

<div class="space-y-4">
	<div>
		<label for="wifiSSID" class="mb-2 block text-sm font-medium text-blue-500"
			>Network Name (SSID)*</label
		>
		<input
			type="text"
			id="wifiSSID"
			bind:value={ssid}
			placeholder="YourWiFiNetwork"
			class="h-10 w-full rounded-sm bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
			required
		/>
	</div>
	<div>
		<label for="wifiPassword" class="mb-2 block text-sm font-medium text-blue-500"
			>Password {securityValue === 'nopass' ? '(Not Needed for Open Network)' : ''}</label
		>
		<input
			type="password"
			id="wifiPassword"
			bind:value={password}
			placeholder={securityValue === 'nopass' ? '' : 'YourNetworkPassword'}
			class="bg-gray-700 text-gray-100"
			class:h-10={true}
			class:w-full={true}
			class:rounded-sm={true}
			class:border={true}
			class:border-black={true}
			class:px-4={true}
			class:text-sm={true}
			class:focus:ring-2={true}
			class:focus:ring-black={true}
			class:focus:outline-none={true}
			class:cursor-not-allowed={securityValue === 'nopass'}
			class:bg-gray-100={securityValue === 'nopass'}
			disabled={securityValue === 'nopass'}
		/>
	</div>
	<div>
		<label class="mb-2 block text-sm font-medium text-blue-500">Security Type</label>
		<Select.Root type="single" bind:value={securityValue}>
			<Select.Trigger
				class="flex h-10 w-full items-center justify-between rounded-sm border border-black bg-gray-700 px-4 py-2 text-sm whitespace-nowrap text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none disabled:cursor-not-allowed disabled:opacity-50"
				aria-label="Wi-Fi Security Type"
			>
				<span>{currentWifiSecurityLabel}</span>
				<svg
					width="16"
					height="16"
					viewBox="0 0 16 16"
					fill="none"
					xmlns="http://www.w3.org/2000/svg"
					class="opacity-50"
				>
					<path
						d="M4 6L8 10L12 6"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					></path>
				</svg>
			</Select.Trigger>
			<Select.Portal>
				<Select.Content
					class="data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95 data-[side=bottom]:slide-in-from-top-2 data-[side=left]:slide-in-from-right-2 data-[side=right]:slide-in-from-left-2 data-[side=top]:slide-in-from-bottom-2 relative z-50 max-h-96 min-w-[var(--radix-select-trigger-width)] overflow-hidden rounded-md border bg-white text-black shadow-md"
				>
					<Select.Viewport class="p-1">
						{#each securityOptions as option (option.value)}
							<Select.Item
								value={option.value}
								label={option.label}
								class="relative flex w-full cursor-default items-center rounded-sm py-1.5 pr-2 pl-8 text-sm outline-none select-none hover:bg-gray-100 focus:bg-gray-100 data-[disabled]:pointer-events-none data-[disabled]:opacity-50"
							>
								<!-- <Select.ItemIndicator
									class="absolute left-2 flex h-3.5 w-3.5 items-center justify-center"
								>
									<svg viewBox="0 0 8 8" fill="currentColor" class="h-4 w-4">
										<circle cx="4" cy="4" r="3"></circle>
									</svg>
								</Select.ItemIndicator> -->
								<span class="block truncate">{option.label}</span>
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
			id="wifiHidden"
			bind:checked={isHidden}
			class="h-4 w-4 rounded border-gray-300 text-gray-100 accent-black focus:ring-black"
		/>
		<label for="wifiHidden" class="text-sm font-medium text-gray-100">Hidden Network</label>
	</div>
	<p class="text-xs text-gray-600">* SSID is required to generate a functional Wi-Fi QR code.</p>
</div>
