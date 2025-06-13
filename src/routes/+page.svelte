<script>
	import { Select } from 'bits-ui';
	import { Button } from 'bits-ui';
	import { Slider } from 'bits-ui';
	import QRCode from 'qrcode';
	import TextForm from '$lib/qr_code_templates/TextForm.svelte';
	import WifiForm from '$lib/qr_code_templates/WifiForm.svelte';
	import VCardForm from '$lib/qr_code_templates/VCardForm.svelte';
	import CalendarEventForm from '$lib/qr_code_templates/CalendarEventForm.svelte';

	// Constants for canvas rendering
	const CANVAS_QR_PADDING = 10; // Padding around the QR code graphic on the canvas
	const CANVAS_TITLE_FONT_SIZE = 20; // Font size for the title
	const CANVAS_TITLE_AREA_VERTICAL_PADDING = 5; // Vertical padding above and below the title text (each side)

	let selectedModeValue = $state('wifi');
	let qrTitle = $state('');
	let activeFormOutput = $state('');
	let activeFilenameHint = $state('');

	let qrCodeDataURL = $state('');
	let size = $state(256); // This is the size of the QR code graphic itself
	let errorCorrectionLevel = $state('M');
	let isGenerating = $state(false);

	let darkColor = $state('#000000');
	let lightColor = $state('#ffffff');

	const modeOptions = [
		{ value: 'text', label: 'Text' },
		{ value: 'wifi', label: 'Wi-Fi Network' },
		{ value: 'vcard', label: 'Contact Card (VCard)' },
		{ value: 'calendar', label: 'Calendar Event' }
	];

	const currentModeLabel = $derived(
		modeOptions.find((opt) => opt.value === selectedModeValue)?.label
	);

	// Derived values for UI display dimensions, reacting to `size` and `qrTitle`
	let titleUiExtraHeight = $derived(
		qrTitle.trim() ? CANVAS_TITLE_FONT_SIZE + CANVAS_TITLE_AREA_VERTICAL_PADDING * 2 : 0
	);
	// Width of the generated image (canvas)
	let qrImageActualWidth = $derived(size + CANVAS_QR_PADDING * 2);
	// Height of the generated image (canvas)
	let qrImageActualHeight = $derived(size + CANVAS_QR_PADDING * 2 + titleUiExtraHeight);

	function downloadQRCode() {
		if (!qrCodeDataURL) return;

		const link = document.createElement('a');
		const timestamp = Date.now();
		let baseFilename = 'qrcode';

		const titleTrimmed = qrTitle.trim();
		if (titleTrimmed) {
			baseFilename = titleTrimmed.replace(/[^-\w\s]/g, '').replace(/\s+/g, '_');
		} else if (activeFilenameHint) {
			baseFilename = activeFilenameHint.replace(/[^-\w\s]/g, '').replace(/\s+/g, '_');
		}

		link.download = `${baseFilename}-${size}-${timestamp}.png`;
		link.href = qrCodeDataURL;
		link.click();
	}

	$effect(() => {
		const capturedSize = size;
		const capturedErrorCorrectionLevel = errorCorrectionLevel;
		const textToEncode = activeFormOutput;
		const capturedQrTitle = qrTitle;
		const capturedDarkColor = darkColor;
		const capturedLightColor = lightColor;

		(async () => {
			if (!textToEncode.trim()) {
				qrCodeDataURL = '';
				return;
			}

			isGenerating = true;
			try {
				const qrOptions = {
					width: capturedSize,
					margin: 0, // We handle padding on the canvas
					color: {
						dark: capturedDarkColor,
						light: '#00000000' // Transparent light color for QR, canvas bg will be lightColor
					},
					errorCorrectionLevel: capturedErrorCorrectionLevel
				};
				// Generate QR code as a data URL (this is the QR pattern only)
				const rawQrDataUrl = await QRCode.toDataURL(textToEncode, qrOptions);

				// Draw QR and title onto a new canvas
				await new Promise((resolve, reject) => {
					const img = new Image();
					img.onload = () => {
						const canvas = document.createElement('canvas');
						const ctx = canvas.getContext('2d');
						const titleText = capturedQrTitle.trim();

						const titleAreaHeightOnCanvas = titleText
							? CANVAS_TITLE_FONT_SIZE + CANVAS_TITLE_AREA_VERTICAL_PADDING * 2
							: 0;

						canvas.width = capturedSize + CANVAS_QR_PADDING * 2;
						canvas.height = capturedSize + CANVAS_QR_PADDING * 2 + titleAreaHeightOnCanvas;

						// Fill canvas background with the chosen light color
						ctx.fillStyle = capturedLightColor;
						ctx.fillRect(0, 0, canvas.width, canvas.height);

						// Draw QR code image onto the canvas
						ctx.drawImage(img, CANVAS_QR_PADDING, CANVAS_QR_PADDING, capturedSize, capturedSize);

						// If title is provided, draw it below the QR code
						if (titleText) {
							ctx.fillStyle = capturedDarkColor; // Title text color
							ctx.font = `${CANVAS_TITLE_FONT_SIZE}px Arial`; // Consider making font family configurable
							ctx.textAlign = 'center';
							ctx.textBaseline = 'top'; // Align the top of the text to the Y coordinate

							const titleTextY =
								CANVAS_QR_PADDING + // Top padding for QR on canvas
								capturedSize + // QR graphic height
								CANVAS_TITLE_AREA_VERTICAL_PADDING; // Padding above title text

							ctx.fillText(titleText, canvas.width / 2, titleTextY);
						}

						// Update reactive state with the new Data URL from canvas
						qrCodeDataURL = canvas.toDataURL('image/png');
						resolve();
					};
					img.onerror = (errEvent) => {
						console.error('Error loading QR code image for canvas drawing:', errEvent);
						qrCodeDataURL = ''; // Clear QR code on error
						reject(new Error('Failed to load QR image onto canvas.'));
					};
					img.src = rawQrDataUrl;
				});
			} catch (error) {
				console.error('Error in QR generation pipeline:', error);
				qrCodeDataURL = '';
			} finally {
				isGenerating = false;
			}
		})();
	});
</script>

<div class="flex min-h-screen items-center justify-center bg-gray-900 p-4 md:p-6 lg:p-8">
	<div class="fixed top-0 left-0 bg-gray-900 p-4 font-[Megrim] text-4xl text-blue-400">QRding</div>
	<div class="w-full max-w-[1080px] bg-gray-900">
		<div class="flex flex-col items-center gap-8 lg:flex-row lg:items-center">
			<!-- Left Section -->
			<div class="w-full max-w-md space-y-6 lg:w-[350px] lg:flex-none">
				<!-- Mode Selector -->
				<div>
					<label for="template" class="mb-2 block text-sm font-medium text-blue-500">Template</label
					>
					<Select.Root type="single" bind:value={selectedModeValue}>
						<Select.Trigger
							id="template"
							class="flex h-10 w-full items-center justify-between rounded-md bg-[#d9ff7a] px-4 text-sm font-medium shadow-sm transition-colors hover:bg-[#bede68]"
						>
							<span>{currentModeLabel}</span>
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
								class="z-50 overflow-hidden rounded-lg border border-black bg-gray-700 text-gray-200 shadow-lg"
								sideOffset={10}
							>
								<Select.Viewport class="p-1">
									{#each modeOptions as option}
										<Select.Item
											value={option.value}
											class="cursor-pointer rounded px-4 py-2 text-sm hover:bg-gray-100 data-[highlighted]:bg-gray-800"
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

				<!-- QR Code Title Input -->
				<div>
					<label for="qrTitle" class="mb-2 block text-sm font-medium text-blue-500"
						>QR Code Title (Optional)</label
					>
					<input
						type="text"
						id="qrTitle"
						bind:value={qrTitle}
						class="block w-full rounded-md border-gray-600 bg-gray-700 p-2.5 text-sm text-white placeholder-gray-400 shadow-sm focus:border-blue-500 focus:ring-blue-500"
						placeholder="Enter title (displays on image)"
					/>
				</div>

				<!-- Input Fields based on Mode -->
				{#if selectedModeValue === 'wifi'}
					<WifiForm
						bind:generatedString={activeFormOutput}
						bind:filenameHint={activeFilenameHint}
					/>
				{:else if selectedModeValue === 'text'}
					<TextForm
						bind:generatedString={activeFormOutput}
						bind:filenameHint={activeFilenameHint}
					/>
				{:else if selectedModeValue === 'vcard'}
					<VCardForm
						bind:generatedString={activeFormOutput}
						bind:filenameHint={activeFilenameHint}
					/>
				{:else if selectedModeValue === 'calendar'}
					<CalendarEventForm
						bind:generatedString={activeFormOutput}
						bind:filenameHint={activeFilenameHint}
					/>
				{/if}

				<!-- Size Slider -->
				<div class="space-y-3">
					<div class="flex items-center justify-between">
						<label class="text-sm font-medium text-blue-600">QR Size</label>
						<span class="text-sm font-medium text-blue-400">{size}px</span>
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
							class="relative h-2 w-full grow cursor-pointer overflow-hidden rounded-full bg-gray-600"
						>
							<Slider.Range class="absolute h-full bg-blue-500" />
						</span>
						<Slider.Thumb
							index={0}
							class="block h-4 w-4 cursor-pointer rounded-full border-2 border-black bg-white shadow-sm transition-shadow hover:shadow-md focus:ring-2 focus:ring-black focus:ring-offset-2 focus:outline-none"
						/>
					</Slider.Root>
				</div>
			</div>

			<!-- Right Section: QR Code Display and Actions -->
			<div
				class="mx-auto flex w-full max-w-[584px] flex-col items-center justify-center space-y-6 lg:w-auto lg:flex-none"
			>
				<!-- QR Code Display Area: Loading, Image, or Placeholder -->
				<!-- The outer div's size is determined by qrImageActualWidth/Height + its own padding (p-4 = 1rem = 16px, so 32px total) -->
				{#if isGenerating}
					<div
						class="mx-auto flex items-center justify-center rounded-lg border border-gray-500 p-4"
						style="width: {qrImageActualWidth + 32}px; height: {qrImageActualHeight + 32}px;"
					>
						<div
							class="h-8 w-8 animate-spin rounded-full border-2 border-gray-300 border-t-blue-500"
						></div>
					</div>
				{:else if qrCodeDataURL}
					<div
						class="mx-auto rounded-lg border border-gray-600 bg-gray-800 p-4 shadow-lg"
						style="width: {qrImageActualWidth + 32}px; height: {qrImageActualHeight + 32}px;"
					>
						<img
							src={qrCodeDataURL}
							alt="Generated QR Code{qrTitle.trim() ? ' with title: ' + qrTitle.trim() : ''}"
							class="block"
							style="width: {qrImageActualWidth}px; height: {qrImageActualHeight}px;"
						/>
					</div>
				{:else}
					<div
						class="mx-auto flex flex-col items-center justify-center rounded-lg border border-dashed border-gray-700 p-4 text-center"
						style="width: {qrImageActualWidth + 32}px; height: {qrImageActualHeight + 32}px;"
					>
						<svg
							class="mb-2 h-12 w-12 text-gray-600"
							fill="none"
							viewBox="0 0 24 24"
							stroke="currentColor"
							stroke-width="1"
						>
							<path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
							<path stroke-linecap="round" stroke-linejoin="round" d="M7 7h10v10H7z" />
						</svg>
						<p class="text-sm text-gray-500">QR code will appear here</p>
						<p class="text-xs text-gray-600">Configure options to generate</p>
					</div>
				{/if}

				<!-- Color Pickers and Download Button (only if QR code is visible) -->
				{#if qrCodeDataURL && !isGenerating}
					<div
						class="qr-color-inputs flex flex-wrap items-center justify-center gap-4"
						style="max-width: {qrImageActualWidth + 32}px;"
					>
						<label class="flex items-center text-sm text-blue-500">
							<span class="mr-2">Dark Color:</span>
							<input
								type="color"
								bind:value={darkColor}
								class="h-8 w-8 cursor-pointer rounded border border-blue-600 bg-gray-700 p-0"
							/>
						</label>
						<label class="flex items-center text-sm text-blue-500">
							<span class="mr-2">Light Color:</span>
							<input
								type="color"
								bind:value={lightColor}
								class="h-8 w-8 cursor-pointer rounded border border-blue-600 bg-gray-700 p-0"
							/>
						</label>
					</div>

					<Button.Root
						onclick={downloadQRCode}
						class="h-10 cursor-pointer rounded-lg bg-[#d9ff7a] px-6 text-sm font-medium text-gray-800 transition-colors hover:bg-[#bede68] data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50"
					>
						Download Image
					</Button.Root>
				{/if}
			</div>
		</div>
	</div>
</div>

<style>
	/* Make color input clickable area cover the preview box better */
	input[type='color']::-webkit-color-swatch-wrapper {
		padding: 0;
	}
	input[type='color']::-webkit-color-swatch {
		border: none;
		border-radius: 0.25rem; /* Match rounded */
	}
	input[type='color']::-moz-color-swatch {
		border: none;
		border-radius: 0.25rem; /* Match rounded */
	}
</style>
