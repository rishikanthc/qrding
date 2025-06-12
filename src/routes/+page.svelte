<script>
	import { Select } from 'bits-ui';
	import { Button } from 'bits-ui';
	import { Slider } from 'bits-ui';
	import QRCode from 'qrcode';
	import TextForm from '$lib/qr_code_templates/TextForm.svelte';
	import WifiForm from '$lib/qr_code_templates/WifiForm.svelte';
	import VCardForm from '$lib/qr_code_templates/VCardForm.svelte';
	import CalendarEventForm from '$lib/qr_code_templates/CalendarEventForm.svelte';

	let selectedModeValue = $state('wifi');

	// Calendar Event Details state variables are now moved to CalendarEventForm.svelte
	let activeFormOutput = $state('');
	let activeFilenameHint = $state('');

	let qrCodeDataURL = $state('');
	let size = $state(256);
	let errorCorrectionLevel = $state('M');
	let isGenerating = $state(false);

	const modeOptions = [
		{ value: 'text', label: 'Text' },
		{ value: 'wifi', label: 'Wi-Fi Network' },
		{ value: 'vcard', label: 'Contact Card (VCard)' },
		{ value: 'calendar', label: 'Calendar Event' }
	];

	const currentModeLabel = $derived(
		modeOptions.find((opt) => opt.value === selectedModeValue)?.label
	);

	// All generate...String and getTextToEncode functions are removed
	// as their logic is now within their respective child components.
	// Child components will update `activeFormOutput`.

	// Download QR code as image
	function downloadQRCode() {
		if (!qrCodeDataURL) return;

		const link = document.createElement('a');
		// Make filename more unique to try and bust browser cache for downloads
		const timestamp = Date.now();
		let baseFilename = 'qrcode';
		if (activeFilenameHint) {
			baseFilename = activeFilenameHint.replace(/[^\\w-]/g, '_');
		}
		// All mode-specific filename logic removed, activeFilenameHint handles this.
		// Append current size and timestamp to the filename
		link.download = `${baseFilename}-${size}-${timestamp}.png`;
		link.href = qrCodeDataURL;
		link.click();
	}

	// Auto-generate QR code when inputs change
	$effect(() => {
		// Capture reactive values from component state for this specific effect run
		const capturedModeValue = selectedModeValue;
		// WiFi state captures removed as WifiForm manages its own state
		// const capturedCustomText = customText; // Removed, TextForm output used directly
		const capturedSize = size;
		const capturedErrorCorrectionLevel = errorCorrectionLevel;
		// const capturedSimpleTestInput = simpleTestInput;

		// console.log('Page - capturedSimpleTestInput:', capturedSimpleTestInput);
		// console.log('Page - capturedSize for slider:', capturedSize);
		// console.log('Page - activeFormOutput from child:', activeFormOutput);

		// vCard details capture removed, VCardForm manages its own state
		// Calendar event details capture removed, CalendarEventForm manages its own state

		// All form-specific data is now in activeFormOutput, provided by the active child component.
		// The getTextToEncode function is removed.
		const textToEncode = activeFormOutput;

		// Use an Immediately Invoked Async Function Expression (IIAFE)
		// to handle the asynchronous QR code generation.
		(async () => {
			if (!textToEncode.trim()) {
				qrCodeDataURL = '';
				// isGenerating should be false if we return early and no generation happens.
				// However, isGenerating is set to true only if we proceed.
				return;
			}

			isGenerating = true;
			try {
				// QRCode is now imported statically at the top
				const options = {
					width: capturedSize, // Use captured size from the effect's scope
					margin: 2,
					color: {
						dark: '#7c3aed',
						light: '#fffbe0'
					},
					errorCorrectionLevel: capturedErrorCorrectionLevel // Use captured ECL
				};
				// Assign to a temporary variable first to ensure the await completes
				// before updating the reactive state.
				const dataUrl = await QRCode.toDataURL(textToEncode, options);
				qrCodeDataURL = dataUrl;
			} catch (error) {
				console.error('Error generating QR code:', error);
				qrCodeDataURL = ''; // Clear QR code on error
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
					<Select.Root type="single" bind:value={selectedModeValue}>
						<label for="template" class="mb-2 block text-sm font-medium text-blue-500"
							>Template</label
						>
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

				<!-- Input Fields -->
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
						<label class="text-sm font-medium text-blue-600">Size</label>
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

			<!-- Right Section -->
			<div
				class="mx-auto flex w-full max-w-[584px] flex-col items-center justify-center space-y-6 lg:w-auto lg:flex-none"
			>
				{#if isGenerating}
					<div
						class="mx-auto flex w-full max-w-full items-center justify-center rounded-lg border border-black p-4"
						style="width: {size + 32}px; height: {size + 32}px;"
					>
						<div
							class="h-8 w-8 animate-spin rounded-full border-2 border-gray-300 border-t-black"
						></div>
					</div>
				{:else if qrCodeDataURL}
					<div
						class="mx-auto w-full max-w-full rounded-lg border border-black p-4"
						style="width: {size + 32}px; height: {size + 32}px;"
					>
						<img
							src={qrCodeDataURL}
							alt="QR Code"
							class="block h-auto max-w-full object-contain"
							style="width: {size}px; height: {size}px;"
						/>
					</div>
				{:else}
					<div
						class="mx-auto flex w-full max-w-full items-center justify-center rounded-lg border border-dashed border-gray-300"
						style="width: {size + 32}px; height: {size + 32}px;"
					>
						<p class="text-sm text-gray-500">QR code will appear here</p>
					</div>
				{/if}

				{#if qrCodeDataURL}
					<Button.Root
						onclick={downloadQRCode}
						disabled={isGenerating}
						class="h-10 cursor-pointer rounded-lg  bg-[#d9ff7a] px-6 text-sm font-medium text-gray-800 transition-colors hover:bg-[#bede68] data-[disabled]:cursor-not-allowed data-[disabled]:opacity-50"
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
