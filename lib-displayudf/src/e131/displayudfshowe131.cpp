/**
 * @file displayudfshowe131.cpp
 *
 */
/* Copyright (C) 2019-2023 by Arjan van Vught mailto:info@orangepi-dmx.nl
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <cstdint>
#include <algorithm>

#include "displayudf.h"
#include "e131bridge.h"
#include "e131.h"

#include "debug.h"

void DisplayUdf::Show(E131Bridge *pE131Bridge, uint32_t nDmxPortIndexOffset) {
	DEBUG_ENTRY

	m_nPortIndexOffset = nDmxPortIndexOffset;

	DEBUG_PRINTF("m_nDmxPortIndexOffset=%u", m_nPortIndexOffset);

	Show();
	
#if defined (OUTPUT_DMX_ARTNET)
	uint16_t nUniverse;
	if (pE131Bridge->GetUniverse(0, nUniverse, lightset::PortDir::OUTPUT)) {
		Printf(m_aLabels[static_cast<uint32_t>(displayudf::Labels::UNIVERSE)], "U: %d", nUniverse);
	}
#endif

	Printf(m_aLabels[static_cast<uint32_t>(displayudf::Labels::AP)], "AP: %d", pE131Bridge->GetActiveOutputPorts() + pE131Bridge->GetActiveInputPorts());

	for (uint32_t nPortIndex = 0; nPortIndex < std::min(4U, e131bridge::MAX_PORTS); nPortIndex++) {
		uint16_t nUniverse;

		if (pE131Bridge->GetUniverse(nPortIndex + m_nPortIndexOffset, nUniverse, lightset::PortDir::OUTPUT)) {
			Printf(m_aLabels[static_cast<uint32_t>(displayudf::Labels::UNIVERSE_PORT_A) + nPortIndex], "Port %c: %d %s", ('A' + nPortIndex), nUniverse, lightset::get_merge_mode(pE131Bridge->GetMergeMode(nPortIndex + m_nPortIndexOffset), true));
		}
	}

	ShowDmxInfo();

	DEBUG_EXIT
}
