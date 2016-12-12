# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils

DESCRIPTION="Plex's official Plex add-on for Kodi."
HOMEPAGE="http://plex.tv/"
MY_PN="script.plex"
COMMIT="c037efbe32e64102830ec3434748fa772d1eb656"
SRC_URI="https://github.com/plexinc/plex-for-kodi/archive/${COMMIT}.zip -> ${P}.zip"

LICENSE="PMS-EULA"
SLOT="0"
KEYWORDS="-* ~amd64 ~x86"
IUSE=""

DEPEND="
	>=media-libs/kodi-platform-16.0
	>=media-tv/kodi-16.0
"

RDEPEND="
	${DEPEND}
"

S="${WORKDIR}/${PN}-${COMMIT}"

src_install() {
	insinto "/usr/share/kodi/addons/${MY_PN}"
	doins -r "${S}/"*
}
