#pragma once
#include <vector>

#include "CASBaseObject.h"
#include "CASSQLItem.h"

class CBinaryStringBuilder;
class CASSQLGrid : public CASBaseGCObject{
public:
    //Only for c++ not expose to as
    CASSQLGrid();
    ~CASSQLGrid();
    static CASSQLGrid* Factory(size_t row, size_t column);
    void Set(size_t row, size_t column, CASSQLItem* pItem);
    //Angel Scripts
    CASSQLItem*  Get(size_t row, size_t column);
    CASSQLItem* opIndex(size_t row, size_t column);
    size_t Rows();
    size_t Columns();
private:
    std::vector <std::vector<CASSQLItem*>> m_aryData;
    size_t m_iRow;
    size_t m_iColumn;
};