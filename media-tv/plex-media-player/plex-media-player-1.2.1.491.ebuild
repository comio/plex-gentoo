# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit eutils cmake-utils

DESCRIPTION="next generation Plex client"
HOMEPAGE="http://plex.tv/"

COMMIT="b014ec9d"
MY_PV="${PV}-${COMMIT}"
MY_P="${PN}-${MY_PV}"

SRC_URI="
	https://github.com/plexinc/${PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
"

LICENSE="GPL-2 PMS-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="cec +desktop joystick lirc"

CDEPEND="
	>=dev-qt/qtcore-5.7.1
	>=dev-qt/qtnetwork-5.7.1
	>=dev-qt/qtxml-5.7.1
	>=dev-qt/qtwebchannel-5.7.1[qml]
	>=dev-qt/qtwebengine-5.7.1
	>=dev-qt/qtx11extras-5.7.1
	>=media-video/mpv-0.11.0[libmpv]
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXrandr

	cec? (
		>=dev-libs/libcec-2.2.0
	)

	joystick? (
		media-libs/libsdl2
		virtual/libiconv
	)
"

DEPEND="
	${CDEPEND}
"

RDEPEND="
	${CDEPEND}

	lirc? (
		app-misc/lirc
	)
"

PATCHES=( "${FILESDIR}/git-revision.patch" )

S="${WORKDIR}/${MY_P}"

CMAKE_IN_SOURCE_BUILD=1

src_unpack() {
	unpack "${P}".tar.gz
}

src_prepare() {
	sed -i -e '/^  install(FILES ${QTROOT}\/resources\/qtwebengine_devtools_resources.pak DESTINATION resources)$/d' src/CMakeLists.txt

	cmake-utils_src_prepare

	eapply_user

	CONAN_USER_HOME="${S}" conan remote add plex http://conan.plex.tv || die
	CONAN_USER_HOME="${S}" conan install -o include_desktop=$(usex desktop True False) || die
}

src_configure() {
	local mycmakeargs=(
		-DENABLE_CEC=$(usex cec)
		-DENABLE_SDL2=$(usex joystick)
		-DENABLE_LIRC=$(usex lirc)
		-DQTROOT=/usr
	)

	export BUILD_NUMBER="${BUILD}"
	export GIT_REVISION="${COMMIT}"

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	# menu items
	domenu "${FILESDIR}/plexmediaplayer.desktop"
	insinto "/usr/share/xsessions"
	doins "${FILESDIR}/plexmediaplayer-session.desktop"

	newicon -s 16 "${FILESDIR}/plexmediaplayer-16x16.png" plexmediaplayer.png
	newicon -s 24 "${FILESDIR}/plexmediaplayer-24x24.png" plexmediaplayer.png
	newicon -s 32 "${FILESDIR}/plexmediaplayer-32x32.png" plexmediaplayer.png
	newicon -s 48 "${FILESDIR}/plexmediaplayer-48x48.png" plexmediaplayer.png
	newicon -s 256 "${FILESDIR}/plexmediaplayer-256x256.png" plexmediaplayer.png
}
