<script>
	// vCard Contact Details
	let name = $state(''); // Mandatory
	let phone = $state('');
	let email = $state('');
	let org = $state('');
	let title = $state('');
	let street = $state('');
	let city = $state('');
	let v_state = $state(''); // Region/Province
	let zip = $state(''); // Postal Code
	let country = $state('');
	let website = $state('');
	let note = $state('');

	let { generatedString = $bindable(), filenameHint = $bindable() } = $props();

	// Helper to escape characters for vCard strings
	function escapeVCardString(str) {
		if (!str) return '';
		return str
			.replace(/\\/g, '\\\\')
			.replace(/,/g, '\\,')
			.replace(/;/g, '\\;')
			.replace(/\n/g, '\\n');
	}

	// Generate vCard string
	function generateVCardStringLocal(
		p_name,
		p_phone,
		p_email,
		p_org,
		p_title,
		p_street,
		p_city,
		p_v_state,
		p_zip,
		p_country,
		p_website,
		p_note
	) {
		const escName = escapeVCardString(p_name);
		const escPhone = escapeVCardString(p_phone);
		const escEmail = escapeVCardString(p_email);
		const escOrg = escapeVCardString(p_org);
		const escTitle = escapeVCardString(p_title);
		const escStreet = escapeVCardString(p_street);
		const escCity = escapeVCardString(p_city);
		const escVState = escapeVCardString(p_v_state);
		const escZip = escapeVCardString(p_zip);
		const escCountry = escapeVCardString(p_country);
		const escWebsite = escapeVCardString(p_website);
		const escNote = escapeVCardString(p_note);

		if (!p_name.trim()) return ''; // Name is mandatory for a valid vCard string

		let vCard = 'BEGIN:VCARD\nVERSION:3.0\n';
		vCard += `N:${escName};;;;\n`; // Simplified: Full Name as Last Name part for N property
		vCard += `FN:${escName}\n`;

		if (escOrg) vCard += `ORG:${escOrg}\n`;
		if (escTitle) vCard += `TITLE:${escTitle}\n`;
		if (escPhone) vCard += `TEL;TYPE=CELL:${escPhone}\n`;
		if (escEmail) vCard += `EMAIL:${escEmail}\n`;

		if (escStreet || escCity || escVState || escZip || escCountry) {
			vCard += `ADR;TYPE=HOME:;;${escStreet};${escCity};${escVState};${escZip};${escCountry}\n`;
		}

		if (escWebsite) vCard += `URL:${escWebsite}\n`;
		if (escNote) vCard += `NOTE:${escNote}\n`;

		vCard += 'END:VCARD';
		return vCard;
	}

	$effect(() => {
		generatedString = generateVCardStringLocal(
			name,
			phone,
			email,
			org,
			title,
			street,
			city,
			v_state,
			zip,
			country,
			website,
			note
		);
		const hintName = name.trim() ? name.replace(/\s+/g, '_') : 'details';
		filenameHint = `contact-${hintName.replace(/[^\\w-]/g, '_')}`;
	});
</script>

<div class="space-y-4">
	<p class="text-xs text-gray-600">Enter contact details. Full Name is required.</p>
	<div>
		<label for="vCardName" class="mb-2 block text-sm font-medium text-blue-500">Full Name*</label>
		<input
			type="text"
			id="vCardName"
			bind:value={name}
			placeholder="John Doe"
			class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-blue-700 focus:outline-none"
			required
		/>
	</div>
	<div>
		<label for="vCardPhone" class="mb-2 block text-sm font-medium text-blue-500">Phone Number</label
		>
		<input
			type="tel"
			id="vCardPhone"
			bind:value={phone}
			placeholder="+1234567890"
			class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<div>
		<label for="vCardEmail" class="mb-2 block text-sm font-medium text-blue-500"
			>Email Address</label
		>
		<input
			type="email"
			id="vCardEmail"
			bind:value={email}
			placeholder="john.doe@example.com"
			class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<div>
		<label for="vCardOrg" class="mb-2 block text-sm font-medium text-blue-500">Organization</label>
		<input
			type="text"
			id="vCardOrg"
			bind:value={org}
			placeholder="ACME Corp"
			class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<div>
		<label for="vCardTitle" class="mb-2 block text-sm font-medium text-blue-500">Job Title</label>
		<input
			type="text"
			id="vCardTitle"
			bind:value={title}
			placeholder="Software Engineer"
			class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<!-- Address Fields -->
	<div class="pt-2">
		<label class="mb-2 block text-sm font-medium text-blue-500">Address</label>
		<input
			type="text"
			bind:value={street}
			placeholder="Street Address (e.g., 123 Main St)"
			class="mb-2 h-10 w-full rounded-lg border border-black bg-gray-700 px-4 text-sm text-gray-100 focus:ring-2 focus:ring-black focus:outline-none"
		/>
		<input
			type="text"
			bind:value={city}
			placeholder="City (e.g., Anytown)"
			class="mb-2 h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
		<div class="grid grid-cols-2 gap-x-2">
			<input
				type="text"
				bind:value={v_state}
				placeholder="State/Province"
				class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
			/>
			<input
				type="text"
				bind:value={zip}
				placeholder="Zip/Postal Code"
				class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
			/>
		</div>
		<input
			type="text"
			bind:value={country}
			placeholder="Country (e.g., USA)"
			class="mt-2 h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<div>
		<label for="vCardWebsite" class="mb-2 block text-sm font-medium text-blue-500">Website</label>
		<input
			type="url"
			id="vCardWebsite"
			bind:value={website}
			placeholder="https://example.com"
			class="h-10 w-full rounded-md border border-black bg-gray-700 px-4 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		/>
	</div>
	<div>
		<label for="vCardNote" class="mb-2 block text-sm font-medium text-blue-500">Note</label>
		<textarea
			id="vCardNote"
			bind:value={note}
			placeholder="Additional notes"
			rows={3}
			class="shadow-mdborder w-full resize-none rounded-md border-black bg-gray-700 px-4 py-3 text-sm text-gray-100 shadow-md focus:ring-2 focus:ring-black focus:outline-none"
		></textarea>
	</div>
</div>
