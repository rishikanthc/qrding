<script>
	let customText = $state('');
	let { generatedString = $bindable(), filenameHint = $bindable() } = $props();

	$effect(() => {
		generatedString = customText;
		filenameHint = 'custom-text'; // Static hint for text
	});
</script>

<div>
	<label for="customText" class="mb-2 block text-sm font-medium">Your Text</label>
	<textarea
		id="customText"
		bind:value={customText}
		placeholder="Enter any text you want to encode"
		rows={4}
		class="w-full resize-none rounded-lg border border-black px-4 py-3 text-sm focus:ring-2 focus:ring-black focus:outline-none"
	></textarea>
</div>
