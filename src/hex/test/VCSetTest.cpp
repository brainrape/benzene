//---------------------------------------------------------------------------
/** @file
 */
//---------------------------------------------------------------------------

#include <boost/test/auto_unit_test.hpp>

#include "BitsetIterator.hpp"
#include "VCBuilder.hpp"
#include "VCSet.hpp"
#include "ChangeLog.hpp"
#include "GroupBoard.hpp"

using namespace benzene;

//---------------------------------------------------------------------------

namespace {

BOOST_AUTO_TEST_CASE(VCSet_CheckCopy)
{
    GroupBoard bd(11, 11);
    VCSet con1(bd.Const(), BLACK);
    con1.Add(VC(NORTH, SOUTH), 0);
    VCSet con2(con1);
    BOOST_CHECK(con1 == con2);

    con1.Add(VC(NORTH, HEX_CELL_A1), 0);
    BOOST_CHECK(con1 != con2);

    con2 = con1;
    BOOST_CHECK(con1 == con2);

    con1.Add(VC(NORTH, HEX_CELL_C1), 0);
    BOOST_CHECK(con1 != con2);
}

/** @todo Make this test quicker! */
BOOST_AUTO_TEST_CASE(VCSet_CheckRevert)
{
    GroupBoard bd(11, 11);

    bd.startNewGame();
    bd.playMove(BLACK, HEX_CELL_A9);
    bd.playMove(WHITE, HEX_CELL_F5);
    bd.playMove(BLACK, HEX_CELL_I4);
    bd.playMove(WHITE, HEX_CELL_H6);

    ChangeLog<VC> cl;
    VCSet con1(bd.Const(), BLACK);
    con1.SetSoftLimit(VC::FULL, 10);
    con1.SetSoftLimit(VC::SEMI, 25);
    VCSet con2(con1);

    VCBuilderParam param;
    param.max_ors = 4;
    param.and_over_edge = true;
    param.use_greedy_union = true;

    VCBuilder builder(param);
    builder.Build(con1, bd);
    builder.Build(con2, bd);
    BOOST_CHECK(con1 == con2);

#if 0
    for (BitsetIterator p(bd.getEmpty()); p; ++p) {
        bitset_t added[BLACK_AND_WHITE];
        added[BLACK].set(*p);
        bd.absorb();
        bd.playMove(BLACK, *p);
        bd.absorb(*p);

        builder.Build(con2, bd, added, &cl);
        
        //std::cout << cl.dump() << std::endl;

        con2.Revert(cl);
        bd.undoMove(*p);

        BOOST_CHECK(cl.empty());
        BOOST_CHECK(VCSetUtil::EqualOnGroups(con1, con2, bd));
    }
#endif
}

}

//---------------------------------------------------------------------------
