// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.6.0 <0.9.0;

contract ArrayContract {
    uint[2**20] m_aLotOfIntegers;
    bool[2][] m_pairsOfFlags;

    function setAllFlagPairs(bool[2][] memory newPairs) public {
        m_pairsOfFlags = newPairs;
    }

    struct StructType {
        uint[] contents;
        uint moreInfo;
    }
    StructType s;

    function f(uint[] memory c) public {
        StructType storage g = s;
        g.moreInfo = 2;
        g.contents = c;
    }

    function setFlagPair(uint index, bool flagA, bool flagB) public {
        m_pairsOfFlags[index][0] = flagA;
        m_pairsOfFlags[index][1] = flagB;
    }

    function changeFlagArraySize(uint newSize) public {
        if (newSize < m_pairsOfFlags.length) {
            while (m_pairsOfFlags.length > newSize) {
                m_pairsOfFlags.pop();
            }
        } else if (newSize > m_pairsOfFlags.length) {
            while (m_pairsOfFlags.length > newSize) {
                m_pairsOfFlags.push();
            }
        }
    }

    function clear() public {
        delete m_pairsOfFlags;
        delete m_aLotOfIntegers;
        m_pairsOfFlags = new bool[2][](0);
    }

    bytes m_byteData;

    function byteArrays(bytes memory data) public {
        m_byteData = data;
        for (uint i = 0; i < 7; i++) {
            m_byteData.push();
        }
        m_byteData[3] = 0x08;
        delete m_byteData[2];
    }

    function addFlag(bool[2] memory flag) public returns (uint) {
        m_pairsOfFlags.push(flag);
        return m_pairsOfFlags.length;
    }

    function createMemoryArray(uint size) public pure returns (bytes memory) {
        uint[2][] memory arrayOfPairs = new uint[2][](size);
        arrayOfPairs[0] = [uint(1), 2];

        bytes memory b = new bytes(200);
        for (uint i = 0; i < b.length; i++) {
            b[i]= bytes1(uint8(i));
        }
        return b;
    }
}