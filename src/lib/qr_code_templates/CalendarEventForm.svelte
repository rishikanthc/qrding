<script>
	let title = $state('');
	let dtStart = $state(''); // Expected format from datetime-local: YYYY-MM-DDTHH:MM
	let dtEnd = $state(''); // Expected format from datetime-local: YYYY-MM-DDTHH:MM
	let location = $state('');

	let { generatedString = $bindable(), filenameHint = $bindable() } = $props();

	// Helper to format date-time strings from datetime-local input
	// Input: YYYY-MM-DDTHH:MM -> Output: YYYYMMDDTHHMMSS (floating local time)
	// Input: YYYY-MM-DD (if it were date only) -> Output: YYYYMMDD
	function formatVEventDateTime(dateTimeString) {
		if (!dateTimeString) return '';
		let dt = dateTimeString; // e.g., "2023-10-26T10:30"
		// Ensure seconds are present for DTSTART/DTEND if time is specified
		// datetime-local input is YYYY-MM-DDTHH:MM. We need YYYYMMDDTHHMMSS.
		if (dt.includes('T') && dt.match(/T\d{2}:\d{2}$/)) {
			dt += ':00'; // Appends seconds, making it YYYY-MM-DDTHH:MM:SS
		}
		// Remove all hyphens and colons, ensure T is preserved if present
		return dt.replace(/[-:]/g, '').replace('T', 'T'); // Becomes YYYYMMDDTHHMMSS or YYYYMMDD
	}

	function getCurrentUTCTimestamp() {
		const now = new Date();
		return (
			now.getUTCFullYear().toString() +
			(now.getUTCMonth() + 1).toString().padStart(2, '0') +
			now.getUTCDate().toString().padStart(2, '0') +
			'T' +
			now.getUTCHours().toString().padStart(2, '0') +
			now.getUTCMinutes().toString().padStart(2, '0') +
			now.getUTCSeconds().toString().padStart(2, '0') +
			'Z'
		);
	}

	function generateCalendarEventStringLocal(p_title, p_dtStart, p_dtEnd, p_location) {
		if (!p_title.trim() || !p_dtStart.trim() || !p_dtEnd.trim()) {
			return '';
		}

		const uid = `qrding-event-${Date.now()}@qrding.com`; // Basic unique ID

		const veventParts = [
			'BEGIN:VEVENT',
			`UID:${uid}`,
			`DTSTAMP:${getCurrentUTCTimestamp()}`,
			`SUMMARY:${p_title}`,
			`DTSTART:${formatVEventDateTime(p_dtStart)}`,
			`DTEND:${formatVEventDateTime(p_dtEnd)}`
		];

		if (p_location.trim()) {
			veventParts.push(`LOCATION:${p_location}`);
		}

		veventParts.push('END:VEVENT');
		return veventParts.join('\n');
	}

	$effect(() => {
		generatedString = generateCalendarEventStringLocal(title, dtStart, dtEnd, location);
		const hintTitle = title.trim() ? title.replace(/\s+/g, '_') : 'event';
		filenameHint = `event-${hintTitle.replace(/[^\\w-]/g, '_')}`;
	});
</script>

<div class="space-y-4">
	<div>
		<label for="eventTitle" class="mb-2 block text-sm font-medium">Event Title*</label>
		<input
			type="text"
			id="eventTitle"
			bind:value={title}
			placeholder="e.g., Team Meeting"
			class="h-10 w-full rounded-lg border border-black px-4 text-sm focus:ring-2 focus:ring-black focus:outline-none"
			required
		/>
	</div>
	<div>
		<label for="eventDTStart" class="mb-2 block text-sm font-medium">Start Date & Time*</label>
		<input
			type="datetime-local"
			id="eventDTStart"
			bind:value={dtStart}
			class="h-10 w-full rounded-lg border border-black px-4 text-sm focus:ring-2 focus:ring-black focus:outline-none"
			required
		/>
	</div>
	<div>
		<label for="eventDTEnd" class="mb-2 block text-sm font-medium">End Date & Time*</label>
		<input
			type="datetime-local"
			id="eventDTEnd"
			bind:value={dtEnd}
			class="h-10 w-full rounded-lg border border-black px-4 text-sm focus:ring-2 focus:ring-black focus:outline-none"
			required
		/>
	</div>
	<div>
		<label for="eventLocation" class="mb-2 block text-sm font-medium">Location</label>
		<input
			type="text"
			id="eventLocation"
			bind:value={location}
			placeholder="e.g., Conference Room 1"
			class="h-10 w-full rounded-lg border border-black px-4 text-sm focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<p class="text-xs text-gray-600">* Mandatory fields. Browser will prompt for YYYY-MM-DDTHH:MM.</p>
</div>
