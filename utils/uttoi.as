int uttoi( USE_TYPE m_UseType )
{
    return m_UseType == USE_OFF ? 0 : m_UseType == USE_ON ? 1 : m_UseType == USE_SET ? 2 : m_UseType == USE_KILL ? 4 : 3;
}