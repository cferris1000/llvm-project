
if (DOXYGEN_FOUND)
if (LLVM_ENABLE_DOXYGEN)
  set(abs_top_srcdir ${CMAKE_CURRENT_SOURCE_DIR})
  set(abs_top_builddir ${CMAKE_CURRENT_BINARY_DIR})

  if (HAVE_DOT)
    set(DOT ${LLVM_PATH_DOT})
  endif()

  if (LLVM_DOXYGEN_EXTERNAL_SEARCH)
    set(enable_searchengine "YES")
    set(searchengine_url "${LLVM_DOXYGEN_SEARCHENGINE_URL}")
    set(enable_server_based_search "YES")
    set(enable_external_search "YES")
    set(extra_search_mappings "${LLVM_DOXYGEN_SEARCH_MAPPINGS}")
  else()
    set(enable_searchengine "NO")
    set(searchengine_url "")
    set(enable_server_based_search "NO")
    set(enable_external_search "NO")
    set(extra_search_mappings "")
  endif()

  # If asked, configure doxygen for the creation of a Qt Compressed Help file.
  if (LLVM_ENABLE_DOXYGEN_QT_HELP)
    set(MLIR_DOXYGEN_QCH_FILENAME "org.llvm.mlir.qch" CACHE STRING
      "Filename of the Qt Compressed help file")
    set(MLIR_DOXYGEN_QHP_NAMESPACE "org.llvm.mlir" CACHE STRING
      "Namespace under which the intermediate Qt Help Project file lives")
    set(MLIR_DOXYGEN_QHP_CUST_FILTER_NAME "MLIR ${MLIR_VERSION}" CACHE STRING
      "See http://qt-project.org/doc/qt-4.8/qthelpproject.html#custom-filters")
    set(MLIR_DOXYGEN_QHP_CUST_FILTER_ATTRS "MLIR,${MLIR_VERSION}" CACHE STRING
      "See http://qt-project.org/doc/qt-4.8/qthelpproject.html#filter-attributes")
    set(mlir_doxygen_generate_qhp "YES")
    set(mlir_doxygen_qch_filename "${MLIR_DOXYGEN_QCH_FILENAME}")
    set(mlir_doxygen_qhp_namespace "${MLIR_DOXYGEN_QHP_NAMESPACE}")
    set(mlir_doxygen_qhelpgenerator_path "${LLVM_DOXYGEN_QHELPGENERATOR_PATH}")
    set(mlir_doxygen_qhp_cust_filter_name "${MLIR_DOXYGEN_QHP_CUST_FILTER_NAME}")
    set(mlir_doxygen_qhp_cust_filter_attrs "${MLIR_DOXYGEN_QHP_CUST_FILTER_ATTRS}")
  else()
    set(mlir_doxygen_generate_qhp "NO")
    set(mlir_doxygen_qch_filename "")
    set(mlir_doxygen_qhp_namespace "")
    set(mlir_doxygen_qhelpgenerator_path "")
    set(mlir_doxygen_qhp_cust_filter_name "")
    set(mlir_doxygen_qhp_cust_filter_attrs "")
  endif()

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/doxygen.cfg.in
    ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg @ONLY)

  set(abs_top_srcdir)
  set(abs_top_builddir)
  set(DOT)
  set(enable_searchengine)
  set(searchengine_url)
  set(enable_server_based_search)
  set(enable_external_search)
  set(extra_search_mappings)
  set(mlir_doxygen_generate_qhp)
  set(mlir_doxygen_qch_filename)
  set(mlir_doxygen_qhp_namespace)
  set(mlir_doxygen_qhelpgenerator_path)
  set(mlir_doxygen_qhp_cust_filter_name)
  set(mlir_doxygen_qhp_cust_filter_attrs)

  add_custom_target(doxygen-mlir
    COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/doxygen.cfg
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating mlir doxygen documentation." VERBATIM)
  set_target_properties(doxygen-mlir PROPERTIES FOLDER "MLIR/Docs")

  if (LLVM_BUILD_DOCS)
    add_dependencies(doxygen doxygen-mlir)
  endif()

  if (NOT LLVM_INSTALL_TOOLCHAIN_ONLY)
    install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doxygen/html
      DESTINATION docs/html)
  endif()
endif()
endif()

