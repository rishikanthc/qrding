<script>
	import { onMount } from 'svelte';

	let mode = $state('wifi'); // 'wifi' or 'text'
	let wifiSSID = $state('');
	let wifiPassword = $state('');
	let wifiSecurity = $state('WPA');
	let wifiHidden = $state(false);
	let customText = $state('');

	let qrCodeDataURL = $state('');
	let size = $state(256);
	let errorCorrectionLevel = $state('M');
	let isGenerating = $state(false);

	// Generate WiFi QR code string
	function generateWiFiString() {
		// WiFi QR code format: WIFI:T:WPA;S:MyNetwork;P:MyPassword;H:false;;
		// For WPA3-Personal-Transition, use WPA (which covers WPA/WPA2/WPA3)
		const security = wifiSecurity;
		const ssid = wifiSSID.replace(/[\\;,:]/g, '\\$&'); // Escape special characters
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
				width: size,
				margin: 2,
				color: {
					dark: '#000000',
					light: '#FFFFFF'
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

<div class="container">
	<h1>WiFi & QR Code Generator</h1>

	<div class="mode-selector">
		<button class="mode-btn {mode === 'wifi' ? 'active' : ''}" onclick={() => (mode = 'wifi')}>
			📶 WiFi Credentials
		</button>
		<button class="mode-btn {mode === 'text' ? 'active' : ''}" onclick={() => (mode = 'text')}>
			📝 Custom Text
		</button>
	</div>

	<div class="input-section">
		{#if mode === 'wifi'}
			<div class="wifi-form">
				<h3>🔐 WiFi Network Details</h3>

				<div class="form-group">
					<label for="ssid">Network Name (SSID) *</label>
					<input
						id="ssid"
						type="text"
						bind:value={wifiSSID}
						placeholder="Enter your WiFi network name"
						required
					/>
				</div>

				<div class="form-group">
					<label for="password">Password</label>
					<input
						id="password"
						type="password"
						bind:value={wifiPassword}
						placeholder="Enter WiFi password (leave empty for open networks)"
					/>
				</div>

				<div class="form-row">
					<div class="form-group">
						<label for="security">Security Type</label>
						<select id="security" bind:value={wifiSecurity}>
							<option value="WPA">WPA/WPA2/WPA3 (Recommended)</option>
							<option value="SAE">WPA3-Personal</option>
							<option value="WPA">WPA2-Personal</option>
							<option value="WEP">WEP (Legacy)</option>
							<option value="nopass">Open (No Password)</option>
						</select>
					</div>

					<div class="form-group checkbox-group">
						<label class="checkbox-label">
							<input type="checkbox" bind:checked={wifiHidden} />
							Hidden Network
						</label>
					</div>
				</div>

				{#if wifiSSID}
					<div class="wifi-preview">
						<h4>📋 Connection String Preview:</h4>
						<code>{generateWiFiString()}</code>
					</div>
				{/if}
			</div>
		{:else}
			<div class="text-form">
				<h3>📝 Custom Text</h3>
				<div class="form-group">
					<label for="custom-text">Enter text or URL:</label>
					<textarea
						id="custom-text"
						bind:value={customText}
						placeholder="Enter text, URL, or any data you want to encode..."
						rows="4"
					></textarea>
				</div>
			</div>
		{/if}

		<div class="options">
			<div class="form-group">
				<label for="size-input">Size: {size}px</label>
				<input id="size-input" type="range" min="128" max="512" step="32" bind:value={size} />
			</div>

			<div class="form-group">
				<label for="error-level">Error Correction:</label>
				<select id="error-level" bind:value={errorCorrectionLevel}>
					<option value="L">Low (7%)</option>
					<option value="M">Medium (15%)</option>
					<option value="Q">Quartile (25%)</option>
					<option value="H">High (30%)</option>
				</select>
			</div>
		</div>
	</div>

	<div class="output-section">
		{#if isGenerating}
			<div class="loading">
				<div class="spinner"></div>
				<p>Generating QR code...</p>
			</div>
		{:else if qrCodeDataURL}
			<div class="qr-result">
				<img src={qrCodeDataURL} alt="Generated QR Code" />
				<div class="result-actions">
					<button onclick={downloadQRCode} class="download-btn"> 💾 Download QR Code </button>
					{#if mode === 'wifi'}
						<div class="instructions">
							<h4>📱 How to use:</h4>
							<ul>
								<li><strong>iPhone:</strong> Open Camera app and point at QR code</li>
								<li><strong>Android:</strong> Use Camera app or WiFi settings QR scanner</li>
								<li><strong>Note:</strong> For WPA3 networks, ensure your device supports WPA3</li>
								<li><strong>Guests:</strong> Scan to automatically connect to your WiFi!</li>
							</ul>
						</div>
					{/if}
				</div>
			</div>
		{:else}
			<div class="placeholder">
				<p>
					{mode === 'wifi'
						? '📶 Enter your WiFi network details above to generate a connection QR code'
						: '📝 Enter some text above to generate a QR code'}
				</p>
			</div>
		{/if}
	</div>
</div>

<style>
	.container {
		max-width: 700px;
		margin: 0 auto;
		padding: 2rem;
		font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
	}

	h1 {
		text-align: center;
		color: #333;
		margin-bottom: 2rem;
	}

	.mode-selector {
		display: flex;
		gap: 0.5rem;
		margin-bottom: 2rem;
		justify-content: center;
	}

	.mode-btn {
		background: #f8f9fa;
		border: 2px solid #ddd;
		padding: 0.75rem 1.5rem;
		border-radius: 8px;
		cursor: pointer;
		transition: all 0.2s;
		font-size: 1rem;
	}

	.mode-btn:hover {
		background: #e9ecef;
		border-color: #007bff;
	}

	.mode-btn.active {
		background: #007bff;
		color: white;
		border-color: #007bff;
	}

	.input-section {
		background: #f8f9fa;
		padding: 2rem;
		border-radius: 12px;
		margin-bottom: 2rem;
	}

	.wifi-form h3,
	.text-form h3 {
		margin-top: 0;
		color: #333;
		border-bottom: 2px solid #007bff;
		padding-bottom: 0.5rem;
	}

	.form-group {
		margin-bottom: 1.5rem;
	}

	.form-row {
		display: grid;
		grid-template-columns: 2fr 1fr;
		gap: 1rem;
		align-items: end;
	}

	label {
		display: block;
		margin-bottom: 0.5rem;
		font-weight: 600;
		color: #555;
	}

	input[type='text'],
	input[type='password'],
	textarea,
	select {
		width: 100%;
		padding: 0.75rem;
		border: 2px solid #ddd;
		border-radius: 6px;
		font-size: 1rem;
		box-sizing: border-box;
		transition: border-color 0.2s;
	}

	input[type='text']:focus,
	input[type='password']:focus,
	textarea:focus,
	select:focus {
		outline: none;
		border-color: #007bff;
	}

	.checkbox-group {
		display: flex;
		align-items: center;
	}

	.checkbox-label {
		display: flex;
		align-items: center;
		gap: 0.5rem;
		font-weight: 600;
		cursor: pointer;
	}

	input[type='checkbox'] {
		width: auto;
		margin: 0;
	}

	.wifi-preview {
		background: #e9ecef;
		padding: 1rem;
		border-radius: 6px;
		margin-top: 1rem;
	}

	.wifi-preview h4 {
		margin: 0 0 0.5rem 0;
		color: #666;
	}

	code {
		background: #fff;
		padding: 0.5rem;
		border-radius: 4px;
		font-family: 'Monaco', 'Menlo', monospace;
		font-size: 0.9rem;
		word-break: break-all;
		display: block;
	}

	.options {
		display: grid;
		grid-template-columns: 1fr 1fr;
		gap: 1.5rem;
		margin-top: 2rem;
		padding-top: 2rem;
		border-top: 1px solid #ddd;
	}

	input[type='range'] {
		width: 100%;
		margin: 0.5rem 0;
	}

	.output-section {
		text-align: center;
		min-height: 350px;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.loading {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1rem;
	}

	.spinner {
		width: 40px;
		height: 40px;
		border: 4px solid #f3f3f3;
		border-top: 4px solid #007bff;
		border-radius: 50%;
		animation: spin 1s linear infinite;
	}

	@keyframes spin {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}

	.qr-result {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1.5rem;
	}

	.qr-result img {
		border: 3px solid #ddd;
		border-radius: 12px;
		box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
	}

	.result-actions {
		display: flex;
		flex-direction: column;
		align-items: center;
		gap: 1.5rem;
	}

	.download-btn {
		background: #28a745;
		color: white;
		border: none;
		padding: 1rem 2rem;
		border-radius: 8px;
		font-size: 1.1rem;
		cursor: pointer;
		transition: background 0.2s;
		font-weight: 600;
	}

	.download-btn:hover {
		background: #218838;
	}

	.instructions {
		background: #e8f4fd;
		padding: 1.5rem;
		border-radius: 8px;
		border-left: 4px solid #007bff;
		text-align: left;
		max-width: 400px;
	}

	.instructions h4 {
		margin-top: 0;
		color: #007bff;
	}

	.instructions ul {
		margin: 0;
		padding-left: 1.2rem;
	}

	.instructions li {
		margin-bottom: 0.5rem;
	}

	.placeholder {
		color: #666;
		font-style: italic;
		padding: 2rem;
	}

	@media (max-width: 768px) {
		.container {
			padding: 1rem;
		}

		.input-section {
			padding: 1.5rem;
		}

		.form-row {
			grid-template-columns: 1fr;
		}

		.options {
			grid-template-columns: 1fr;
		}

		.mode-selector {
			flex-direction: column;
		}
	}
</style>
